resource "aws_sns_topic" "spot_instance_notifications" {
  name = "spot-instance-notifications"
}

resource "aws_sns_topic_subscription" "spot_interrupt_subscription" {
  topic_arn = aws_sns_topic.spot_instance_notifications.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"  # Replace with your email address
}

resource "aws_cloudwatch_event_rule" "spot_interruption_rule" {
  name        = "spot-instance-interruption"
  description = "Capture EC2 Spot Interruption Warnings"
  event_pattern = jsonencode({
    "source": [
      "aws.ec2"
    ],
    "detail-type": [
      "EC2 Spot Instance Interruption Warning"
    ]
  })
}

resource "aws_cloudwatch_event_target" "spot_interruption_to_sns" {
  rule      = aws_cloudwatch_event_rule.spot_interruption_rule.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.spot_instance_notifications.arn
}

# resource "aws_lambda_permission" "allow_cloudwatch_to_call_sns" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_sns_topic.spot_instance_notifications.arn
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.spot_interruption_rule.arn
# }

