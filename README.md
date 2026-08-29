# Server Templating with HasiCorp Packer
Automate Image Builds Across Platforms
Packer Eliminates Manual Steps for Golden Image Creation

### Core components of packer
- Packer builds images using a template and templates can be built using HCL2
- Templates defines settings using blocks:
 - Original image to use "source"
 - Where to build the image "AWS, VMware, OpenStack"
 - Files to upload to the image "Scripts, packages, certificates"
 - Installation and configuration of Machine image
 - Data to retrieve when building

 Source > Variables > Communicators > Builders > Provisioner > Post-Processors

 ### Source:
 Defines the initial image to use to create your customized image. Any defined source is reusable within build blocks. 

 ```bash
source "azure-arm" "azure-arm-centos-7" {
    image_offer = "CentOS"
    image_publisher = "OpenLogic"
    image_sku = "7.7"
    os_type = "Linux"
    subscription_id = "${var.azure_subscription_id}"
    }
 ```



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
