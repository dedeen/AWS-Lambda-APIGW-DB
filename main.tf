*  Terraform to build a lambda function, API gateway, and neccessary IAM policies. 
      Use at your own peril, and be mindful of the AWS costs of 
      building this environment.  
        -- Dan Edeen, dan@dsblue.net, 2022  --
	   
*/
provider "aws" {
  alias = "usw2"
  region = "us-west-2"

  default_tags {
    tags = {
      Owner = "dan-via-terraform"
    }
  }
}

variable "policy_name"{
  type = string
  default = "LambdaAPIGatewayPolicy"
}

resource "aws_iam_policy" "policy" {
  name        	= var.policy_name
  description 	= "IAM Policy for Lambda Setup"
  tags          = "dan-via-terraform"

  policy = file("lambda_api_gw_policy.json")
}
