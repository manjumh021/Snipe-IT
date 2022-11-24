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
  key_name               = "aws-manju-key2"
  vpc_security_group_ids = [sg-0b20fefb47205d6ba]
  connection {
    type    = "ssh"
    host    = self.public_ip
    user    = "ubuntu"
    timeout = "4m"
  }
  tags = {
    Name = "dev-environment"
  }
}