#CREATING S3 BUCKET NOTIFICATION TO SEND TO LAMBDA
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.incoming_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
