#!/usr/bin/bash
sudo chown ec2-user:ec2-user /etc/yum.repos.d/zscaler.repo -R
cat > /etc/yum.repos.d/zscaler.repo <<-EOT
[zscaler]
name=Zscaler Private Access Repository
baseurl=https://yum.private.zscaler.com/yum/el7
enabled=1
gpgcheck=1
gpgkey=https://yum.private.zscaler.com/gpg
EOT

REGION=$(curl http://169.254.169.254/latest/meta-data/placement/region)
URL="http://169.254.169.254/latest/meta-data/network/interfaces/macs/"
MAC=$(curl $URL)
URL=$URL$MAC"vpc-id/"
VPC=$(curl $URL)
key="ZSDEMO"

# Install the App Connect Software package
sudo yum install zpa-connector -y

# Create provisioning key file
sudo touch /opt/zscaler/var/provision_key
sudo chmod 644 /opt/zscaler/var/provision_key
sudo chown admin:admin /opt/zscaler/var/ -R

sudo chown ec2-user:ec2-user /opt/zscaler/var/ -R
aws ssm get-parameter --name $key --query Parameter.Value --with-decryption --region $REGION | tr -d '"' > /opt/zscaler/var/provision_key

#Run a yum update to apply the latest patches
yum update -y

#Start the App Connector service to enroll it in the ZPA cloud
systemctl start zpa-connector

#Wait for the App Connector to download latest build
sleep 60

#Stop and then start the App Connector for the latest build
systemctl stop zpa-connector
systemctl start zpa-connector