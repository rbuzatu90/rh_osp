#!/bin/bash
### https://access.redhat.com/documentation/en/red-hat-openstack-platform/8/director-installation-and-usage/director-installation-and-usage

OpenstackVersion=10
Username=your_username
hostname=undercloud

hostnamectl --static set-hostname $hostname
hostnamectl --transient set-hostname $hostname 

sed -i "s/.*127.0.0.1*//g" /etc/hosts
echo "127.0.0.1 undercloud localhost localhost.localdomain localhost4 localhost4.localdomain4" >> /etc/hosts

echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-undercloud.conf
systemctl restart systemd-sysctl

useradd -m stack
echo stack|passwd --stdin stack
echo 'stack ALL=(root) NOPASSWD:ALL' | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack
cp -r ~/.ssh /home/stack
chown -R stack:stack /home/stack/.ssh
echo "Enter redhat Subscription password"

subscription-manager register --username=$Username
PoolID=$(subscription-manager list --available|grep -v "^ "|grep -m1 -A 5 "Employee SKU"|awk -F: '/ool/{print $2}'|sed "s/ //g")
subscription-manager attach --pool=$PoolID

subscription-manager repos --disable=*
if [ "$OpenstackVersion" == "beta" ]
then
  baseVersionRPMS=" --enable=rhel-7-server-beta-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-ha-for-rhel-7-server-beta-rpms --enable=rhel-7-server-openstack-beta-rpms --enable rhel-7-fast-datapath-rpms"
else
  baseVersionRPMS="--enable=rhel-7-server-rpms --enable=rhel-7-server-openstack-$OpenstackVersion-rpms "
fi

subscription-manager repos $baseVersionRPMS --enable=rhel-7-server-extras-rpms --enable rhel-7-server-rh-common-rpms


yum -y install rsyslog ntp gpm bash-completion screen deltarpm crudini rsync tcpdump telnet git libguestfs-tools guestfish vim
yum -y update

systemctl enable rsyslog ntpd gpm
systemctl start rsyslog ntpd gpm

echo "###### Preparation finished, REBOOT ######"
