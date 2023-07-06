#! /bin/bash

# Read the GitLab URL we are registering for and the Gitlab token
#URL=$1
#GITLAB_REG_TOKEN=$2

# Update apt packages
sudo apt-get update -y && sudo apt-get upgrade -y



# Install apt requirements
sudo apt-get -y install \
    apt-transport-https \
    lsb-release \
    software-properties-common \
    awscli

# Uninstall docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update -y
sudo apt-get  install ca-certificates curl gnupg -y

# Add Docker’s official GPG key:
sudo rm -r /etc/apt/keyrings/docker.gpg --interactive=never
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get  update -y

# Install docker
sudo apt-get  install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo systemctl enable docker --now




# Installing and configuring Gitlab Runner
sudo curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"

sudo chmod +x /usr/local/bin/gitlab-runner
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
sudo /usr/local/bin/gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner

# Configuring Runner PreStart, Start and Stop Scripts
cat > ~/start-gitlab-runner.sh << EOF
/usr/local/bin/gitlab-runner run            \
  --working-directory "/home/gitlab-runner" \
  --config "/etc/gitlab-runner/config.toml" \
  --service "gitlab-runner"                 \
  --user "gitlab-runner"
EOF


cat > ~/register-gitlab-runner.sh << EOF
/usr/local/bin/gitlab-runner register                          \
  --non-interactive                                            \
  --url "https://gitlab.com"                                \
  --token "glrt-5ZCjiC18yayxHKWuw5S3"                     \
  --request-concurrency 4                                      \
  --executor "docker"
  --docker-image alpine:latest                                    \
  --description "Some Runner Description"                      \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --docker-image "docker:latest"                       \
  ----docker-privileged true                           \
  --docker-tlsverify false                                     \
  --docker-disable-cache false                                 \
  --docker-shm-size 0                                          \
  --locked="true"
EOF



cat > ~/deregister-gitlab-runner.sh << EOF
/usr/local/bin/gitlab-runner "unregister" "--all-runners"
EOF

echo -e "\nMaking scripts executable"
chmod +x ~/{start,register,deregister}-gitlab-runner.sh

# Move scripts to /usr/bin/
sudo mv ~/{start,register,deregister}-gitlab-runner.sh /usr/bin/


echo -e "\nConfigure Gitlab Runner Service Unit File"

cat > ~/gitlab-runner.service << EOF
[Unit]
Description=GitLab Runner
After=syslog.target network.target
ConditionFileIsExecutable=/usr/local/bin/gitlab-runner
[Service]
StartLimitInterval=5
StartLimitBurst=10
ExecStart=/bin/bash /usr/bin/start-gitlab-runner.sh
ExecStartPost=/bin/bash /usr/bin/register-gitlab-runner.sh
ExecStop=/bin/bash /usr/bin/deregister-gitlab-runner.sh
Restart=always
RestartSec=120
[Install]
WantedBy=multi-user.target
EOF

# Move SystemD service unit file to /etc/systemd/system
sudo rm -rf /etc/systemd/system/gitlab-runner.service --interactive=never
sudo mv ~/gitlab-runner.service /etc/systemd/system/
sudo systemctl enable gitlab-runner --now

# Service file changed - refresh systemd daemon
sudo systemctl daemon-reload


echo -e "\nGitlab Runner Installed successfully"
