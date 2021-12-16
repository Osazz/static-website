# Compulsory Variables

variable "aws-account" {
  description = "Aws account id that we deploying to"
  type        = string
  default = "847881920253"
}

variable "codestar-connections-arn" {
  description = "Arn of codestar connection to use by codepipeline to connect to github"
  type        = string
  default     = "arn:aws:codestar-connections:us-east-1:847881920253:connection/89b76fd5-7635-4d73-a7c4-08bbfc1c3a07"
}

# Optional Variables
variable "s3-website-bucket" {
  description = "S3 bucket name to host website"
  type        = string
  default = "static-website-deploy-s3"
}

variable "s3-artifact-bucket" {
  description = "S3 bucket name to host website"
  type        = string
  default = "codepipeline-store-artifacts"
}

variable "aws-region" {
  description = "Aws region where we want to deploy"
  type        = string
  default     = "us-east-1"
}

variable "github-branch" {
  description = "The git hub branch where we want Codepipeline to get code from"
  type        = string
  default     = "main"
}

variable "github-organization" {
  description = "Organisation of Github to use"
  type        = string
  default = "osazz"
}

variable "github-repository" {
  description = "Repository where code is kept"
  type        = string
  default = "static-website"
}
