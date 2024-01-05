#!/bin/bash

# jdk17 install
yum -y install java-17-amazon-corretto-headless.x86_64

# git install
yum -y install git

# clone
cd /home/ec2-user
sudo -u ec2-user git clone https://github.com/namickey/spring-boot3-train.git

# setup ec2
sudo -u ec2-user /bin/bash /home/ec2-user/spring-boot3-train/setup-ec2.sh
