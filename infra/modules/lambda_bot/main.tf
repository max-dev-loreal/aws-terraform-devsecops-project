data "archive_file" "bot" {
  type        = "zip"
  source_file = "${path.module}/../../../bot/lambda_function.py"
  output_path = "${path.module}/../../../bot.zip"
}

resource "aws_lambda_function" "bot" {
  function_name = "${var.name_prefix}-tg-bot"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.bot.output_path
  timeout       = 30
  memory_size   = 256

  role = aws_iam_role.lambda.arn

  environment {
    variables = {
      TELEGRAM_BOT_TOKEN    = var.telegram_bot_token
      TELEGRAM_CHAT_ID      = var.telegram_chat_id
      GITHUB_OWNER          = var.github_owner
      GITHUB_REPO           = var.github_repo
      GITHUB_PAT_SECRET_ARN = var.github_pat_secret_arn
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = "${var.name_prefix}-lambda-bot-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets" {
  name = "${var.name_prefix}-lambda-secrets"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.github_pat_secret_arn
    }]
  })
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.bot.execution_arn}/*/*"
}

resource "aws_apigatewayv2_api" "bot" {
  name          = "${var.name_prefix}-bot-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "bot" {
  api_id                 = aws_apigatewayv2_api.bot.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.bot.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "bot" {
  api_id    = aws_apigatewayv2_api.bot.id
  route_key = "POST /webhook"
  target    = "integrations/${aws_apigatewayv2_integration.bot.id}"
}

resource "aws_apigatewayv2_stage" "bot" {
  api_id      = aws_apigatewayv2_api.bot.id
  name        = "prod"
  auto_deploy = true
}
