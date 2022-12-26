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
	
# Create lambda function (node.js) from local zipped function 
resource "aws_lambda_function" "LambdaFunctionOverHttps" {
	filename	= "function.zip"
	function_name	= "LambdaFunctionOverHttps"
	role		= aws_iam_role.role.arn
	handler		= "index.handler"
	runtime		= "nodejs16.x"
	#environment
}

# Create a REST API for Lambda function
resource "aws_api_gateway_rest_api" "CreatedAPI" {
  name 			= "DynamoDBOps"
  description		= "DynamoDB-Dans_API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create a resource for the REST API
resource "aws_api_gateway_resource" "DynamoDBManager" {
  parent_id   = aws_api_gateway_rest_api.CreatedAPI.root_resource_id
  path_part   = "dynamodbmanager"	# must be lowercase version of resource name above
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI.id
}

# Create an HTTP Post method
resource "aws_api_gateway_method" "HTTPPostMethod" {	
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.DynamoDBManager.id
  rest_api_id   = aws_api_gateway_rest_api.CreatedAPI.id
}


# Add the lambda integration
#variable "myregion" {}
#variable "accountId" {}

resource "aws_api_gateway_integration" "lambda_integration" {
  http_method = aws_api_gateway_method.HTTPPostMethod.http_method
  resource_id = aws_api_gateway_resource.DynamoDBManager.id
  rest_api_id = aws_api_gateway_rest_api.CreatedAPI.id
  integration_http_method = "POST"
  type        = "AWS"   # lets API GW pass req to backend lambda function
  #uri 	      = aws_lambda_function.test_lambda.invoke_arn
  #uri 	      = "${aws_lambda_function.test_lambda.invoke_arn}"
  uri 	      = "${aws_lambda_function.LambdaFunctionOverHttps.invoke_arn}"
  #uri 	      = "arn:aws:lambda:us-west-2:500112433998:function:LambdaFunctionOverHttps"
}


  
	
