## Removing old Docker versions

```sh
sudo apt-get remove docker docker-engine docker.io containerd runc
```

## Installation in Ubuntu:

```sh
curl https://get.docker.com | bash      #DO NOT DO THIS! First save script to file and then run it!
usermod -aG docker USER                 #add your user to "docker" group - no sudo needed
newgrp docker                           #refreshing changes in group settings
```

## Ubuntu installation without script (from repo):

https://docks.docker.com/engine/install/ubuntu

```sh
sudo apt install apt-transport-https curl ca-certificates software-properties-common # Install dependencies
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - # download repository keys, adding them to OS
sudo apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"  #adding repository to sources.list
sudo apt update
sudo apt install docker-ce # Docker Community Edition
```
