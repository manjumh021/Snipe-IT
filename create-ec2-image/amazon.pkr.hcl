packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "snipe-it" {
  ami_name = "snipe-it-app-${local.timestamp}"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-2.*.1-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  instance_type = "t2.micro"
  region = "us-west-1"
  ssh_username = "ec2-user"
  associate_public_ip_address = "false"
  launch_block_device_mappings {
      device_name = "/dev/sda1"
      volume_size = 8
      volume_type = "gp2"
      delete_on_termination = true
      encrypted = false
    }
  
}

build {
  sources = [
    "source.amazon-ebs.snipe-it"
  ]
  provisioner "shell" {
    script = "./Ansible/install-ansible.sh"
  }
  provisioner "ansible" {
      playbook_file = "Ansible/main.yml"
      user = "ec2-user"
    }
}