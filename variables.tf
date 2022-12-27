/* Input vars for lambda-apigw-dynamodb deployment on AWS. 
      Dan Edeen, dan@dsblue.net, 2022 
	  -- variables defined in this file -- 
*/

variable "dyndb_table_1_name" {
	description     = "Table Name for LambdaFunction1"
  default         = "dyndb-table3"
}
  
variable "dyndb_table_2_name" {
	description     = "Table Name for LambdaFunction2"
  default         = "dyndb-table4"
}
  
