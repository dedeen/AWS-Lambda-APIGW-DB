/* Input vars for lambda-apigw-dynamodb deployment on AWS. 
      Dan Edeen, dan@dsblue.net, 2022 
	  -- variables defined in this file -- 
*/

variable "table1_name" {
  description     	= "Table Name for LambdaFunction1"
  default         	= "dyndb-table3"
}
  
variable "table2_name" {
  description     	= "Table Name for LambdaFunction2"
  default         	= "dyndb-table4"
}
	
variable "db_hashkey" {
  description 		= "hash key (partition ID for db tables)"
  default		= "id"
}
  
  
