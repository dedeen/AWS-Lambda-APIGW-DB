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
resource "aws_lambda_function" "test_lambda" {
	filename	= "function.zip"
	function_name	= "LambdaFunctionOverHttps"
	role		= aws_iam_role.role.arn
	handler		= "index.handler"
	runtime		= "nodejs16.x"
	#environment
}

# Create a rest api for Lambda function
resource "aws_api_gateway_rest_api" "created_api" {
  name 			= "DynamoDBOps"
  description		= "DynamoDB-Dans_API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

	
	
