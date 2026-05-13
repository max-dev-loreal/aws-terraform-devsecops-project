import json
import os
import boto3
import urllib.request
import urllib.error
import time
from datetime import datetime, timezone

OWNER = os.environ["GITHUB_OWNER"]
REPO = os.environ["GITHUB_REPO"]
WORKFLOW_FILE = "terraform-apply-dispatch.yml"
PAT_SECRET_ARN = os.environ["GITHUB_PAT_SECRET_ARN"]
ALLOWED_CHAT_ID = int(os.environ["TELEGRAM_CHAT_ID"])
PLAN_BUCKET = os.environ["PLANS_S3_BUCKET"]
MAX_CALLBACK_AGE_MINUTES = 60

secrets_client = boto3.client("secretsmanager", region_name="eu-north-1")
dynamodb = boto3.resource("dynamodb", region_name="eu-north-1")
s3_client = boto3.client("s3", region_name="eu-north-1")

APPROVALS_TABLE = os.environ.get("DYNAMODB_TABLE", "prod-platform-approvals")


def log_event(level, message, extra=None):
    payload = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "level": level,
        "message": message,
        "service": "terraform-approval-bot",
    }
    if extra:
        payload.update(extra)
    print(json.dumps(payload))


def get_pat():
    try:
        val = secrets_client.get_secret_value(SecretId=PAT_SECRET_ARN)
        return json.loads(val["SecretString"])["pat"]
    except Exception as e:
        log_event("ERROR", "Failed to retrieve PAT", {"error": str(e)})
        raise


def send_message(chat_id, text, bot_token, reply_markup=None):
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "Markdown",
    }
    if reply_markup:
        payload["reply_markup"] = json.dumps(reply_markup)

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url, data=data, headers={"Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status
    except urllib.error.HTTPError as e:
        log_event("ERROR", "Telegram API error", {"status": e.code})
        return e.code


def validate_plan_exists(run_id):
    key = f"plans/{run_id}/tfplan"
    try:
        s3_client.head_object(Bucket=PLAN_BUCKET, Key=key)
        return True
    except s3_client.exceptions.ClientError:
        log_event("WARN", "Plan not found in S3", {"run_id": run_id, "key": key})
        return False


def check_idempotency(run_id, action, username):
    table = dynamodb.Table(APPROVALS_TABLE)
    pk = f"{run_id}#{action}"
    try:
        response = table.get_item(Key={"approval_id": pk})
        if "Item" in response:
            existing = response["Item"]
            return False, existing.get("approved_by")
    except Exception as e:
        log_event("ERROR", "DynamoDB read error", {"error": str(e)})
        return True, None
    return True, None


def record_approval(run_id, action, username, message_id):
    table = dynamodb.Table(APPROVALS_TABLE)
    ttl = int(time.time()) + 86400
    try:
        table.put_item(Item={
            "approval_id": f"{run_id}#{action}",
            "run_id": run_id,
            "action": action,
            "approved_by": username,
            "approved_at": datetime.now(timezone.utc).isoformat(),
            "telegram_message_id": message_id,
            "ttl": ttl,
        })
    except Exception as e:
        log_event("ERROR", "Failed to write approval", {"error": str(e)})


def dispatch_github_action(run_id, action, pat):
    url = (
        f"https://api.github.com/repos/{OWNER}/{REPO}/"
        f"actions/workflows/{WORKFLOW_FILE}/dispatches"
    )
    headers = {
        "Authorization": f"token {pat}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json",
        "User-Agent": "TerraformApprovalBot/2.0",
    }
    payload = {
        "ref": "main",
        "inputs": {
            "plan_run_id": run_id,
            "action": action,
        },
    }

    data = json.dumps(payload).encode("utf-8")
    last_error = None

    for attempt in range(1, 4):
        req = urllib.request.Request(url, data=data, headers=headers, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                if resp.status == 204:
                    log_event("INFO", "GitHub dispatch successful", {"attempt": attempt})
                    return True, None
        except urllib.error.HTTPError as e:
            last_error = f"HTTP {e.code}"
            if e.code in (401, 403, 404):
                break
            time.sleep(2 ** attempt)
        except Exception as e:
            last_error = str(e)
            time.sleep(2 ** attempt)

    return False, last_error


def lambda_handler(event, context):
    bot_token = os.environ["TELEGRAM_BOT_TOKEN"]
    body = json.loads(event.get("body", "{}"))
    log_event("INFO", "Incoming webhook", {"body_keys": list(body.keys())})

    if "callback_query" not in body:
        return {"statusCode": 200, "body": "Not a callback"}

    callback = body["callback_query"]
    chat_id = callback["message"]["chat"]["id"]
    message_id = callback["message"]["message_id"]
    callback_date = callback["message"]["date"]

    if chat_id != ALLOWED_CHAT_ID:
        send_message(chat_id, "⛔ Access denied.", bot_token)
        return {"statusCode": 403, "body": "Forbidden"}

    data = callback.get("data", "")
    user = callback.get("from", {})
    username = user.get("username") or user.get("first_name", "unknown")

    try:
        run_id, action = data.split("|", 1)
    except ValueError:
        send_message(chat_id, "⛔ Invalid callback data.", bot_token)
        return {"statusCode": 400, "body": "Bad request"}

    log_event("INFO", "Processing callback", {"run_id": run_id, "action": action, "user": username})

    age_minutes = (time.time() - callback_date) / 60
    if age_minutes > MAX_CALLBACK_AGE_MINUTES:
        send_message(chat_id, f"⌛ Plan expired ({int(age_minutes)} min ago). Create a new plan.", bot_token)
        return {"statusCode": 200, "body": "Plan expired"}

    if action == "cancel":
        send_message(chat_id, f"❌ Plan `{run_id}` cancelled by *{username}*.", bot_token)
        return {"statusCode": 200, "body": "Cancelled"}

    if action == "destroy" and not data.endswith("|destroy|confirmed"):
        keyboard = {
            "inline_keyboard": [[
                {"text": "⚠️ Yes, destroy infrastructure", "callback_data": f"{run_id}|destroy|confirmed"},
                {"text": "❌ Abort", "callback_data": f"{run_id}|cancel"},
            ]]
        }
        send_message(
            chat_id,
            f"🔴 *WARNING*\nYou are about to *DESTROY* plan `{run_id}`.\nThis is irreversible. Confirm:",
            bot_token,
            reply_markup=keyboard,
        )
        return {"statusCode": 200, "body": "Awaiting confirmation"}

    is_unique, first_user = check_idempotency(run_id, action, username)
    if not is_unique:
        send_message(
            chat_id,
            f"⚠️ Action *{action}* for plan `{run_id}` already requested by @{first_user}.",
            bot_token,
        )
        return {"statusCode": 200, "body": "Duplicate blocked"}

    if not validate_plan_exists(run_id):
        send_message(chat_id, f"⛔ Plan `{run_id}` not found in S3.", bot_token)
        return {"statusCode": 404, "body": "Plan not found"}

    try:
        pat = get_pat()
    except Exception as e:
        send_message(chat_id, f"⛔ Secret error: `{str(e)}`", bot_token)
        return {"statusCode": 500, "body": "Secret error"}

    success, error = dispatch_github_action(run_id, action, pat)

    if success:
        record_approval(run_id, action, username, message_id)
        send_message(
            chat_id,
            f"⚡ Dispatched *{action}* for plan `{run_id}`.\n👤 By: @{username}\nCheck GitHub Actions.",
            bot_token,
        )
        return {"statusCode": 200, "body": "Dispatched"}
    else:
        send_message(chat_id, f"⛔ GitHub API error: `{error}`", bot_token)
        return {"statusCode": 500, "body": f"GitHub error: {error}"}
