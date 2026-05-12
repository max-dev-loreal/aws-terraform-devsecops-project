output "webhook_url" {
  value = "${aws_apigatewayv2_api.bot.api_endpoint}/prod/webhook"
}
