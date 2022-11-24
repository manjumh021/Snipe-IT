terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-west-1"
}

resource "aws_instance" "snipe-it_server" {
  ami           = "ami-02ea247e531eb3ce6"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-practice"
  }
}