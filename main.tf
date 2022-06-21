provider "aws" { 
region = "us-east-2"  

}

# THIS IS TO CREATE A ZIP FILE FROM THE .PY FILE FOR LAMBDA
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

# CREATE IAM ROLE FOR LAMBDA AND GIVE IT ALLOW PERMISSION

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM FOR LAMBDA TO get S3

resource "aws_iam_policy" "lambda_can_write_s3" {
  name        = "s3_policy"
  path        = "/"
  description = "MANAGED BY TERRAFORM Allow Lambda to write"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1646328525749",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

# ATTCHING POLICY AND ROLE 

resource "aws_iam_role_policy_attachment" "attach-policy" {
  role       = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.lambda_can_write_to_s3.arn
}
     


# CREATING LAMBDA FUNCTION 
resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda.zip"
  function_name = "lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime = "python3.9"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  environment {
    variables = {
      incoming_bucket_arn = aws_s3_bucket.incoming_bucket.arn
    }
  }
}


# GIVE PERMISSION TO LAMBDA TO ALLOW S3

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.incoming_bucket.arn
}


# CREATING INPUT S3 BUCKET
resource "aws_s3_bucket" "incoming_bucket" {
  bucket = "your-bucket-name"
}



 
# CREATING OUTPUT S3 BUCKET
resource "aws_s3_bucket" "destination_bucket" {
  bucket = "your-bucket-name"
}
  
  
  # TO MOVE IMAGE INTO OUTPUT S3 BUCKET
  
resource "aws_lambda_function_event_invoke_config" "move_to_s3" {
  function_name = aws_lambda_function.test_lambda.function_name
  qualifier     = "$LATEST"
  
  destination_config {
    on_failure {
      destination = aws_s3_bucket.incoming_bucket.arn
    }

    on_success {
      destination = aws_s3_bucket.destination_bucket.arn
    }
  }
}

