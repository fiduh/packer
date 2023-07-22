# Gitlab Runner

### Reference architecture for Automating the templating of a scalable, and cost-effective GitLab Runner on AWS with Packer

Basic knowledge of Terraform, AWS EC2, Packer, and GitLab CI is assumed.

This reference architecture gives practical steps to spin up a cost-effective, automated GitLab Runner setup that scales based on demand and also offers the possibility to switch off the entire stack at predefined time intervals to save cost. 
Gitlab CI gives users an option to selfhost Gitlab Runners

## Bake an Amazon Machine Image (AMI)

Packer uses an HCL config template that defines the entire life cycle of creating customized AMI images. Code snippets below: 

```hcl
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source  = "github.com/hashicorp/amazon"
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
  type        = string
  default     = "us-east-1"
  description = "Default region"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Default instance type"
}

source "amazon-ebs" "aws-gitlab-ami" {
  region        = var.region
  source_ami    = data.amazon-ami.amazon-ami-lts.id
  ami_name      = "Gitlab-Runner-ami-{{timestamp}}"
  instance_type = var.instance_type
  ssh_username  = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.aws-gitlab-ami"]

  provisioner "shell" {
    script = "./gitlab-runner-provision.sh"
  }
}

```


```bash 
packer build gitlab-runner.pkr.hcl

```

The command above spins up a temporary EC2 instance, configures it with a provisioning script (`./gitlab-runner-provision.sh`, in this case), AMI is saved and the EC2 instance destroyed 

## Installing and Configuring GitLab Runners
To successfully run GitLab runners, its executors (e.g. Docker), and subsequently pipeline jobs in EC2 machines, we need some binary dependencies, environment setup, configuration, etc.

To keep things repeatable, we can define all the steps in a shell script, which could then be used by Packer to prepare our custom GitLab Runner AMI, `gitlab-runner-provision.sh`. It'll be given the below list of commands to install, configure, and prepare the Runners - along with the repositories they'll register with.

https://github.com/osemiduh/packer/blob/05be570178619b0a32c641ad3d61a2f0c852b099/gitlab-runner/gitlab-runner-provision.sh#L1-L104

The triggers `ExecStart`, `ExecStartPost`, and `ExecStop` in the systemd service unit file in the above script, acts as hooks for machine events, they start, register and deregister runners attached to GitLab groups or projects. This is important when adding capabilities to shut down the entire Runner cluster during off-work hours (by using schedules in autoscaling groups), and instances need to remove the Runner Registration bindings from GitLab (otherwise, they'll leave stale associations behind).

