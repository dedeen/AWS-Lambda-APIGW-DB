# AWS Lambda Functions via APIGW to DynamoDB Tables
This repo contains scripts to deploy APIGW REST APIs, with Lambda functions, IAM roles and policies, DynamoDB tables, and HTTP methods to post records via URL into the DB tables. This suite is fully functional and can be run in your account.  

Dan Edeen, dan@dsblue.net, 2022 

## Overview
The functionality realized by these scripts:
*  Create policy and role for lambda functions and APIs. 
*  Create (2) lambda functions from .js scripts in the repo. 
*  Create (2) REST APIs, with resources, http methods, integrations, and http responses. 
*  Create (2) DynamoDB tables, one for each API/Lambda function.
*  Output the URL and post strings to create and delete records in both DynamoDB tables. 

----------------------------------


## Prerequisites
There are a a few steps to set up the environment: 
* Log in to your AWS environment and launch a CloudShell terminal window. 
* Clone repo to CloudShell, git is already installed. 
* Run *setup.sh*; this will install Terraform and a couple of other useful tools. 
Environment is ready to run Terraform scripts. 
* Be mindful of locality of resources created, e.g. global IAM resources, regional DB tables and lambda functions. 

## Running .tf Scripts to Build AWS Infrastructure
1. CD to the directory with .tf scripts and run the following commands. Follow the prompts. Run from the region specified in your provider.tf file. 
2. `$terraform init`
3. `$terraform apply`


## Cleaning up AWS Infrastructure

The scripts contained here apply tags in the provider.tf file. These tags can be searched from 
AWS console or CLI to confirm. When you are finished you should delete the resources created. 

`$terraform destroy`

You can confirm the resources have been deleted by again searching on the tags. 
