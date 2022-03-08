# CREATING A REST API GATEWAY 
resource "aws_api_gateway_rest_api" "ak-api" {
  name        = "ServerlessExample"
  description = "Lambda serverless ApiGateway"
  }
  
  resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.ak-api.id}"
  parent_id   = "${aws_api_gateway_rest_api.ak-api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.ak-api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.ak-api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.test_lambda.invoke_arn}"
}

# similar configuration as above, applied to the root resource that is built in to the REST API object.

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.ak-api.id}"
  resource_id   = "${aws_api_gateway_rest_api.ak-api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.ak-api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.test_lambda.invoke_arn}"
}


resource "aws_api_gateway_deployment" "api-deploy" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ak-api.id}"
  stage_name  = "test"
}



resource "aws_api_gateway_authorizer" "ak-auth" {
  name                   = "demo"
  rest_api_id            = "${aws_api_gateway_rest_api.ak-api.id}"
  authorizer_uri         = "${aws_lambda_function.test_lambda.invoke_arn}"
  authorizer_credentials = "${aws_iam_policy.lambda_can_log_and_read_params.arn}"
}


# THIS IS TO ALLOW ACCESS TO THE URL
output "base_url" {
  value = "${aws_api_gateway_deployment.api-deploy.invoke_url}"
}
