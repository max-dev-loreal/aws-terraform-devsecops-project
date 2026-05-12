import json
import os
import boto3
import urllib.request

OWNER = os.environ["GITHUB_OWNER"]
REPO = os.environ["GITHUB_REPO"]
WORKFLOW_FILE = "terraform-dispatch.yml"
PAT_SECRET_ARN = os.environ["GITHUB_PAT_SECRET_ARN"]
ALLOWED_CHAT_ID = int(os.environ["TELEGRAM_CHAT_ID"])


def get_pat():
    client = boto3.client("secretsmanager", region_name="eu-north-1")
    val = client.get_secret_value(SecretId=PAT_SECRET_ARN)
    return json.loads(val["SecretString"])["pat"]


def send_message(chat_id, text, bot_token):
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "Markdown"
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url, data=data, headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req) as resp:
        return resp.status


def lambda_handler(event, context):
    bot_token = os.environ["TELEGRAM_BOT_TOKEN"]
    body = json.loads(event.get("body", "{}"))

    # Telegram шлёт callback_query при нажатии inline-кнопки
    if "callback_query" not in body:
        return {"statusCode": 200, "body": "Not a callback"}

    callback = body["callback_query"]
    chat_id = callback["message"]["chat"]["id"]

    if chat_id != ALLOWED_CHAT_ID:
        send_message(chat_id, "⛔ Access denied.", bot_token)
        return {"statusCode": 403, "body": "Forbidden"}

    data = callback["data"]  # формат: "RUN_ID|apply"

    try:
        run_id, action = data.split("|")
    except ValueError:
        send_message(chat_id, "⛔ Bad callback data.", bot_token)
        return {"statusCode": 400, "body": "Bad request"}

    if action == "cancel":
        send_message(chat_id, f"❌ Plan `{run_id}` cancelled.", bot_token)
        return {"statusCode": 200, "body": "Cancelled"}

    # Берём PAT из Secrets Manager
    try:
        pat = get_pat()
    except Exception as e:
        send_message(chat_id, f"⛔ Secret error: `{str(e)}`", bot_token)
        return {"statusCode": 500, "body": "Secret error"}

    # Дёргаем GitHub API
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/actions/workflows/{WORKFLOW_FILE}/dispatches"
    headers = {
        "Authorization": f"token {pat}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json",
        "User-Agent": "TerraformBot/1.0"
    }
    payload = {
        "ref": "main",
        "inputs": {
            "plan_run_id": run_id,
            "action": action
        }
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )

    try:
        with urllib.request.urlopen(req) as resp:
            status = resp.status
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        send_message(chat_id, f"⛔ GitHub API error: `{e.code}`", bot_token)
        return {"statusCode": 500, "body": f"GitHub error: {err}"}

    if status == 204:
        send_message(
            chat_id,
            f"⚡ Dispatched *{action}* for plan `{run_id}`.\nCheck GitHub Actions.",
            bot_token
        )
        return {"statusCode": 200, "body": "Dispatched"}
    else:
        send_message(chat_id, f"⛔ GitHub returned: `{status}`", bot_token)
        return {"statusCode": 500, "body": f"Status {status}"}
