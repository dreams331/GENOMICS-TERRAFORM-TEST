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

# IAM FOR LAMBDA TO get PARAMETER

resource "aws_iam_policy" "lambda_can_log_and_read_params" {
  name        = "ssm_policy"
  path        = "/"
  description = "MANAGED BY TERRAFORM Allow Lambda to log"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1646328525749",
      "Action": "ssm:*",
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
  policy_arn = aws_iam_policy.lambda_can_log_and_read_params.arn
}
     


# CREATING LAMBDA FUNCTION 
resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda.zip"
  function_name = "lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.8"
  
}


# GIVE PERMISSION TO LAMBDA TO ALLOW API
resource "aws_lambda_permission" "allow-api" {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.ak-api.execution_arn}/*/*/*"
}
