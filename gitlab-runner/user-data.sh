#!/bin/bash

sudo sed -i  "s+TOKEN+glrt-5ZCjiC18yayxHKWuw5S3+g" /usr/bin/register-gitlab-runner.sh

sudo sed -i  "s+URL+https://gitlab.com+g" /usr/bin/register-gitlab-runner.sh

sudo systemctl restart gitlab-runner.service