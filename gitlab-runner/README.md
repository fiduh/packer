# Gitlab Runner

### Reference architecture for Automating the templating of a scalable, and cost-effective GitLab Runner on AWS with Packer

Basic knowledge of Terraform, AWS EC2, Packer, and GitLab CI is assumed.

This reference architecture gives practical steps to spin up a cost-effective, automated GitLab Runner setup that scales based on demand and also offers the possibility to switch off the entire stack at predefined time intervals to save cost. 
Gitlab CI gives users an option to selfhost Gitlab Runners

Packer uses an HCL config template that defines the entire life cycle of creating customized AMI images. Code snippets below: 


`packer build packer-build.pkr.hcl`

The command above spins up a temporary EC2 instance, configures it with a provisioning script (./provision.sh, in this case), AMI is saved and EC2 instance destroyed 

## Installing and Configuring GitLab Runners
To successfully run GitLab runners, it's executors (e.g. Docker) and subsequently pipeline jobs in EC2 machines, we'd need some binary dependencies, environment setup, configuration, etc.

https://github.com/osemiduh/packer/blob/05be570178619b0a32c641ad3d61a2f0c852b099/gitlab-runner/gitlab-runner-provision.sh#L1-L104

To keep things repeatable, we can define all the steps in a shell script, which could then be used by Packer to prepare our custom GitLab Runner AMI, provision.sh. It'll be given the below list of commands to install, configure, and prepare the Runners - along with the repositories they'll register with.
