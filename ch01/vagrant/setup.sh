#!/bin/bash

echo '--------'
echo "setup.sh as: $(whoami)"
echo '--------'

DOCKER_VERSION="5:19.03.12~3-0~ubuntu-xenial"
KUBERNETES_VERSION="1.18.8-00"
hostname -I | awk '{print $NF}' > /tmp/ip.txt

# turn off swap - for the Kubelet
swapoff -a 
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# install Docker
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y \
    docker-ce=$DOCKER_VERSION \
    docker-ce-cli=$DOCKER_VERSION \
    containerd.io

# use Docker & Kind without sudo:
sudo usermod -aG docker vagrant

# install Kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y \
    kubectl=$KUBERNETES_VERSION

# install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind