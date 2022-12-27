/*  Terraform to build a lambda function, API gateway, and neccessary IAM policies. 
      Use at your own peril, and be mindful of the AWS costs of 
      building this environment.  
        -- Dan Edeen, dan@dsblue.net, 2022  --
	   
*/
variable "policy_name"{
  type 		= string
  default 	= "LambdaAPIGatewayPolicy"
}

variable "role_name"{
  type 		= string
  default 	= "LambdaAPIGatewayRole"
}


resource "aws_iam_policy" "policy" {
  name          = var.policy_name
  description   = "IAM Policy for Lambda Function"
  policy        = file("lambda_api_gw_policy.json")
  tags          = {
    Owner       = "dan-via-terraform"
  }
}

resource "aws_iam_role" "role" {
  name			= var.role_name
  description		= "IAM Role for Lambda Function"
  tags          	= {
    Owner       = "dan-via-terraform"
  }
#  assume_role_policy 	= "${aws_iam_policy.policy.arn}"
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

# Policy attachment to the role
resource "aws_iam_role_policy_attachment" "policy_attach" {
	role 		= aws_iam_role.role.name
	policy_arn 	= aws_iam_policy.policy.arn
}
	
# Create lambda function from local zipped function1 
resource "aws_lambda_function" "LambdaFunction1" {
	filename	= "function1.zip"
	function_name	= "LambdaFunction1"
	role		= aws_iam_role.role.arn
	handler		= "index1.handler"
	runtime		= "nodejs16.x"
	#environment
}
# Create lambda function from local zipped function2 
resource "aws_lambda_function" "LambdaFunction2" {
	filename	= "function2.zip"
	function_name	= "LambdaFunction2"
	role		= aws_iam_role.role.arn
	handler		= "index2.handler"
	runtime		= "nodejs16.x"
	#environment
}

# Create a REST API for Lambda function1
resource "aws_api_gateway_rest_api" "CreatedAPI1" {
  name 			= "DynamoDB1"
  description		= "DynamoDB-Dans_API1"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create a REST API for Lambda function2
resource "aws_api_gateway_rest_api" "CreatedAPI2" {
  name 			= "DynamoDB2"
  description		= "DynamoDB-Dans_API2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create a resource for the REST API
resource "aws_api_gateway_resource" "DynamoDBManager1" {
  parent_id   = aws_api_gateway_rest_api.CreatedAPI1.root_resource_id
  path_part   = "dynamodbmanager1"	# must be lowercase version of resource name above
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI1.id
}

# Create a resource for the REST API
resource "aws_api_gateway_resource" "DynamoDBManager2" {
  parent_id   = aws_api_gateway_rest_api.CreatedAPI2.root_resource_id
  path_part   = "dynamodbmanager2"	# must be lowercase version of resource name above
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI2.id
}

# Create an HTTP Post method 1
resource "aws_api_gateway_method" "HTTPPostMethod1" {	
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.DynamoDBManager1.id
  rest_api_id   = aws_api_gateway_rest_api.CreatedAPI1.id
}

# Create an HTTP Post method 2
resource "aws_api_gateway_method" "HTTPPostMethod2" {	
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.DynamoDBManager2.id
  rest_api_id   = aws_api_gateway_rest_api.CreatedAPI2.id
}



# Add the lambda integration
#variable "myregion" {}
#variable "accountId" {}

resource "aws_api_gateway_integration" "lambda_integration1" {
  http_method = aws_api_gateway_method.HTTPPostMethod1.http_method
  resource_id = aws_api_gateway_resource.DynamoDBManager1.id
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI1.id
  integration_http_method = "POST"
  type        = "AWS"   # lets API GW pass req to backend lambda function
  #uri 	      = aws_lambda_function.test_lambda.invoke_arn
  #uri 	      = "${aws_lambda_function.test_lambda.invoke_arn}"
  uri 	      = "${aws_lambda_function.LambdaFunction1.invoke_arn}"
  #uri 	      = "arn:aws:lambda:us-west-2:500112433998:function:LambdaFunctionOverHttps"
}

resource "aws_api_gateway_integration" "lambda_integration2" {
  http_method = aws_api_gateway_method.HTTPPostMethod2.http_method
  resource_id = aws_api_gateway_resource.DynamoDBManager2.id
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI2.id
  integration_http_method = "POST"
  type        = "AWS"   # lets API GW pass req to backend lambda function
  #uri 	      = aws_lambda_function.test_lambda.invoke_arn
  #uri 	      = "${aws_lambda_function.test_lambda.invoke_arn}"
  uri 	      = "${aws_lambda_function.LambdaFunction2.invoke_arn}"
  #uri 	      = "arn:aws:lambda:us-west-2:500112433998:function:LambdaFunctionOverHttps"
}

resource "aws_api_gateway_method_response" "response_200_1" {
  http_method = aws_api_gateway_method.HTTPPostMethod1.http_method
  resource_id = aws_api_gateway_resource.DynamoDBManager1.id
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI1.id
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
    }
}

resource "aws_api_gateway_method_response" "response_200_2" {
  http_method = aws_api_gateway_method.HTTPPostMethod2.http_method
  resource_id = aws_api_gateway_resource.DynamoDBManager2.id
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI2.id
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
    }
}

resource "aws_api_gateway_integration_response" "integration_response1" {
  depends_on  = [aws_api_gateway_integration.lambda_integration1]
  http_method = aws_api_gateway_method.HTTPPostMethod1.http_method
  resource_id = aws_api_gateway_resource.DynamoDBManager1.id
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI1.id
  status_code = aws_api_gateway_method_response.response_200_1.status_code
}


resource "aws_api_gateway_integration_response" "integration_response2" {
  depends_on  = [aws_api_gateway_integration.lambda_integration2]
  http_method = aws_api_gateway_method.HTTPPostMethod2.http_method
  resource_id = aws_api_gateway_resource.DynamoDBManager2.id
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI2.id
  status_code = aws_api_gateway_method_response.response_200_2.status_code
}

resource "aws_lambda_permission" "lambda_permission1" {
  statement_id  = "AllowMyAPIInvoke1"
  action        = "lambda:InvokeFunction"
  function_name	= "LambdaFunction1"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.CreatedAPI1.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "lambda_permission2" {
  statement_id  = "AllowMyAPIInvoke2"
  action        = "lambda:InvokeFunction"
  function_name	= "LambdaFunction2"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.CreatedAPI2.execution_arn}/*/*/*"
}

# Set up a couple of dynamo DB tables for the lambda function
resource "aws_dynamodb_table" table1 {
  name			= "dyndb-table1"
  billing_mode		= "PROVISIONED"
  read_capacity 	= 1
  write_capacity 	= 1
  hash_key		= "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags	= {
    Owner = "dan-via-terraform"
  }
}

resource "aws_dynamodb_table" table2 {
  name			= "dyndb-table2"
  billing_mode		= "PROVISIONED"
  read_capacity 	= 1
  write_capacity 	= 1
  hash_key		= "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags	= {
    Owner = "dan-via-terraform"
  }
}

/* ##################
Test post to DBs
{
  "operation": "create",
  "payload": {
    "Item": {
      "id": "1234ABCD",
      "number": 5
    }
  }
}
##################
{
    "operation": "update",
    "payload": {
        "Key": {
            "id": "1234ABCD"
        },
        "AttributeUpdates": {
            "number": {
                "Value": 10
            }
        }
    }
}
################## */
	
