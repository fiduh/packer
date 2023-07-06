packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "amazon-ami-lts" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
  region      = "us-east-1"
}


variable "region" {
  type = string
  default = "us-east-1"
  description = "Default region"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "Default instance type"
}

source "amazon-ebs" "aws-gitlab-ami" {
  region = var.region
  ami_name  = "amazon_gitlab_ami {{timestamp}}"
  instance_type = var.instance_type
  ssh_username         = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.aws-gitlab-ami"]

  provisioner "shell" {
    inline = ["echo GitLab"]
  }
}

