terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      Version = "~>3.27"
    }
  }

  required_version = ">=0.14.9"

}

# Configure the AWS Provider
provider "aws" {
  version = "~>3.0"
  region  = "east-us-1"
}
