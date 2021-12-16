Terraform code to deploy resources to automatically deploy static website from Github using codepipeline and use
cloudfront to deliver content

How to deploy the Resource
Create codestar connections manually to the Github account that you intend to get code from.

Use Github version 2 in aws
Give access to only the repository need
Put in the required variables needed by terraform

aws-account
codestar-connections-arn
Run terraform init

Run terraform plan

Read through the plan to confirm that expected resource will be created
Run Terraform apply

Room for improvement
Create the codestar connection using terraform
Have github action do validations, formatting and output the plan of terraform code
Setup terraform remote state to use aws s3 bucket and locking to use dynamo db
