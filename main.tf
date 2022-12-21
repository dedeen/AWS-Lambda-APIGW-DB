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
	
	
