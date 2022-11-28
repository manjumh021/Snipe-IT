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
  ami = "ami-02ea247e531eb3ce6"
  instance_type = "t2.micro"
  count = 1
  key_name = "aws-manju-key2"
  user_data = "${file("install-ansible.sh")}"
  vpc_security_group_ids = [aws_security_group.main.id]
  
  provisioner "file" {
    source      = "./docker-dc-install.yml"
    destination = "/home/ubuntu/docker-dc-install.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/docker-dc-install.yml",
      "ansible-playbook docker-dc-install.yml",
    ]
  }

  connection {
		type        = "ssh"
		host        = self.public_ip
		user        = "ubuntu"
		private_key = "${{ secrets.AWS_PRIVATE_KEY }}"
		timeout     = "4m"
	}
  tags = {
    Name = "dev-environment"
  }
}

locals {
   ingress_rules = [{
      port        = 22
      description = "Ingress rules for port 22"
   },
   {
      port        = 8000
      description = "Ingree rules for port 8000"
   }]
}

resource "aws_security_group" "main" {
   name   = "resource_with_dynamic_block"
   vpc_id = data.aws_vpc.main.id

   dynamic "ingress" {
      for_each = local.ingress_rules

      content {
         description = ingress.value.description
         from_port   = ingress.value.port
         to_port     = ingress.value.port
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
      }
   }

   egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]

   tags = {
      Name = "AWS security group dynamic block"
   }
}
