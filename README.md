# Server Templating with HasiCorp Packer

### Reference architecture for Automating the templating of a scalable, and cost-effective GitLab Runner on AWS with Packer

Gitlab CI gives users an option to selfhost Gitlab Runners

### Quick Start 
clone this repo
`git clone https://https://github.com/osemiduh/packer.git`

build the Gitlab runner AMI using Packer:

``
cd packer/gitlab-runner
packer build 
``

(aws cli should be logged in) 

Navigate to the AWS Console, Check the EC2 -> AMIs section, and confirm that the new Gitlab runner AMI has been built.
* Launch a new EC2 instance using the AMI ID found in the previous step. 

Use this script in the User data section of the EC2's instance launch options to replace the registration credentials of gitlab runner 

### Prerequisite 
* a [gitlab.com](gitlab.com) account
* Gitlab runner registration token `repository setting -> CI/CD -> Runners -> Specific Runners -> Set up a specific runner manually`
* install [Hasicorp's Packer](https://releases.hashicorp.com/packer/) on the build machine
