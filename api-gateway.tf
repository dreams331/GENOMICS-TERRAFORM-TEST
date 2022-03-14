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
  api_key_required = true
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
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ak-api.id}"
  stage_name  = "test"
}


# THIS IS TO ALLOW ACCESS TO THE URL
output "base_url" {
  value = "${aws_api_gateway_deployment.api-deploy.invoke_url}"
}


resource "aws_api_gateway_stage" "stage-api" {
 	deployment_id = aws_api_gateway_deployment.api-deploy.id
 	rest_api_id = aws_api_gateway_rest_api.ak-api.id
 	stage_name = "stage-api"
 	}

resource "aws_api_gateway_usage_plan" "demo-plan" {
 	name = "usage-plan"
 	description = "my description"
 	product_code = "MYCODE"
 	 
 	api_stages {
 	api_id = aws_api_gateway_rest_api.ak-api.id
 	stage = aws_api_gateway_stage.stage-api.stage_name
 	}
 	 
 	 
 	quota_settings {
 	limit = 20
 	offset = 2
 	period = "WEEK"
 	}
 	 
 	throttle_settings {
 	burst_limit = 5
 	rate_limit = 10
 	}
 	}
 	 
 	# Creating API Key
 	resource "aws_api_gateway_api_key" "api-key" {
 	name = "demo"
 	}
 	 
 	# Attaching API Key to usage plan
 	resource "aws_api_gateway_usage_plan_key" "main" {
 	key_id = aws_api_gateway_api_key.api-key.id
 	key_type = "API_KEY"
 	usage_plan_id = aws_api_gateway_usage_plan.demo-plan.id
 	}
