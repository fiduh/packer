# Server Templating with HasiCorp Packer

### Quick Start 
clone this repo
`git clone https://https://github.com/osemiduh/packer.git`

build the Gitlab runner AMI using Packer:

``
cd packer/gitlab-runner
packer build 
``

(You must authenticate using your AWS secret key and user credentials on the build machine) 

Navigate to the AWS Console, Check the EC2 -> AMIs section, and confirm that the new Gitlab runner AMI has been built.
* Launch a new EC2 instance using the AMI ID found in the previous step. 

Use this script in the User data section of the EC2's instance launch options to replace the registration credentials of GitLab runner 
``` bash
#!/bin/bash

sudo sed -i  "s+TOKEN+glrt-<Insert Registration Token Here>+g" /usr/bin/register-gitlab-runner.sh

sudo sed -i  "s+URL+<Insert the Instance URL Here>+g" /usr/bin/register-gitlab-runner.sh

sudo systemctl restart gitlab-runner.service
```

### Prerequisite 
* a [gitlab.com](gitlab.com) SaaS account or self hosted instance
* Gitlab runner registration token `repository setting -> CI/CD -> Runners -> Specific Runners -> Set up a specific runner manually`
* install [Hasicorp's Packer](https://releases.hashicorp.com/packer/) on the build machine
