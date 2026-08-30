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

### Builders:
Builders are responsible for creating machines from the base image, customizing the image as defined, and then creating a resulting image.
- Builders are plugins thar are developed to work with specific platform (i.e., AWS, Azure, Docker, etc.)

```bash
build {
    source = [""]

    provisioner "file" {
        destination = ""
        source = ""
    }
}
```

### Post-Processors
- Post-processors are executed after the image is built and provisioners are complete. It can be used to upload artifacts, execute uploaded scripts, validate installs, or import an image.

### Communicators
- Communicators are the mechanism that Packer will use to communicate with the new build and upload files, execute scripts. etc.
- Two Communicators available today:
    - SSH
    - WinRM

### Variables
- HashiCorp Packer can use variables to define defaults during a build
- Variables can be declared in a .pkrvars.hcl file or .auto.pkrvars.hcl, the defualt .pkr file, or any other file name if referenced when executing the build.
- You can also declare individually using the --var option

```bash
# Variable declaration block:

variable "image_id" {
type = string
description = "The id of the machine image (AMI) to use for the server."
default: "ami-1234abcd"

validation {
    condition = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
    }
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
