# Gitlab Runner

### Reference architecture for Automating the templating of a scalable, and cost-effective GitLab Runner AMI on AWS with Packer

Basic knowledge of Terraform, AWS EC2, Packer, and GitLab CI is assumed.

This reference architecture gives pratical steps to spin up a cost-effective, automated GitLab Runner setup that scales in/out based on demand and also offers the possibility to switch off the entire stack at predefined time intervals to save cost. 
Gitlab CI gives users an option to selfhost Gitlab Runners

Packer uses a HCL config template that defines the entire life cycle of creating customised AMI images. Code snippets below: 


packer build packer-build.pkr.hcl

The command above spins up a temporary EC2 instance, configures it with a provisioning script (./provision.sh, in this case), AMI is saved and EC2 instance destroyed 

## Installing and Configuring GitLab Runners
To successfully run GitLab runners, it's executors (e.g. Docker) and subsequently pipeline jobs in EC2 machines, we'd need some binary dependencies, environment setup, configuration, etc.

To keep things repeatable, we can define all the steps in a shell script, which could then be used by Packer to prepare our custom GitLab Runner AMI, provision.sh. It'll be given the below list of commands to install, configure, and prepare the Runners - along with the repositories they'll register with.
