#!/bin/bash

# Variables
APT_OPT_1=Dpkg::Options::="--force-confdef"
APT_OPT_2=Dpkg::Options::="--force-confold"

# Refresh the dependencies
rm -rf /var/lib/apt/lists/* && \
sudo apt-get -y clean && \
apt-get -y update -o Acquire::CompressionTypes::Order::=gz && \

# Configure the timezone
DEBIAN_FRONTEND=noninteractive apt-get -yq install tzdata && \
ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata && \

# Make the system up-to-date
DEBIAN_FRONTEND=noninteractive apt-get -y -o $APT_OPT_1 -o $APT_OPT_2 upgrade && \
apt-get -y -o $APT_OPT_1 -o $APT_OPT_2 autoremove && \
apt-get -y -o $APT_OPT_1 -o $APT_OPT_2 autoclean && \

# Install extra tools
apt-get -y install acl bash curl htop iotop mc ntp openssl vim && \

# Activating unattended upgrades
apt-get -y -o $APT_OPT_1 -o $APT_OPT_2 install unattended-upgrades && \
dpkg-reconfigure -f noninteractive unattended-upgrades && \
if [ -z $UNATTENDED_UPGRADE_EMAIL ]; then \
    echo "Unattended-Upgrade::Mail \"$UNATTENDED_UPGRADE_EMAIL\";" >> /etc/apt/apt.conf.d/99-falco && \
    echo 'Unattended-Upgrade::MailReport "on-change";' >> /etc/apt/apt.conf.d/99-falco ; \
fi ; \
echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/99-falco && \
echo 'Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";' >> /etc/apt/apt.conf.d/99-falco && \
echo 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' >> /etc/apt/apt.conf.d/99-falco && \

# Change the default ssh port
echo "Changing the default SSH port..." && \
sed -i 's/^.*\(Port\ \+[0-9]\+\).*$//g' /etc/ssh/sshd_config && \
echo "" >> /etc/ssh/sshd_config && \
echo "# Falco custom configuration" >> /etc/ssh/sshd_config && \
echo "Port 10022" >> /etc/ssh/sshd_config
