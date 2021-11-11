#!/usr/bin/bash
sudo chown ec2-user:ec2-user /etc/yum.repos.d/zscaler.repo -R
sudo cat > /etc/yum.repos.d/zscaler.repo <<-EOT
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

#Run a yum update to apply the latest patches
sudo yum update -y

#Wait for the App Connector to download latest build
sleep 60

# Create provisioning key file
sudo systemctl stop zpa-connector
sudo touch /opt/zscaler/var/provision_key
sudo chmod 644 /opt/zscaler/var/provision_key

sudo chown ec2-user:ec2-user /opt/zscaler/var/ -R
aws ssm get-parameter --name $key --query Parameter.Value --with-decryption --region $REGION | tr -d '"' > /opt/zscaler/var/provision_key

#Start the App Connector service to enroll it in the ZPA cloud
systemctl start zpa-connector