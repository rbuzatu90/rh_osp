#!/bin/bash

set -x

CPU_OPTS="--cpu host"
GRAPHICS_OPTS="--graphics vnc --video=cirrus"
CONTROLLER_OPTS="--controller scsi,model=virtio-scsi,index=0"
MISC_OPTS="--noautoconsole --print-xml --check path_in_use=no"
BOOT_OPTS="--boot cdrom,hd,menu=on"
VMBASE=/vms
VMs="controller-os compute-os network-os"
RESOURCES_OPTS="--ram 4096 --vcpus=2"

# ctlplane no dhcp; mgm-net no dhcp but external with nat
NETWORK_1="--network=network=ctlplane,model=virtio,mac="
NETWORK_2="--network=network=mgmt-net,model=virtio,mac="
NETWORK_3="--network=network=mgmt-net,model=virtio,mac="

INSTALLER_DISK="$VMBASE/images/rhel-server-7.2-x86_64-dvd.iso"
KICKSTART_DISK="$VMBASE/images/ks_disk.img"

DISK_1="--disk=path=$INSTALLER_DISK,device=cdrom"
DISK_2="--disk pool=storage-pool,size=40,format=qcow2,bus=scsi,cache=writeback"
DISK_3="--disk=path=$KICKSTART_DISK,bus=scsi,cache=writeback"

MAC_CONTROLLER1="52:54:00:ae:1d:01"
MAC_CONTROLLER2="52:54:00:ae:1d:02"
MAC_CONTROLLER3="52:54:00:ae:1d:03"
MAC_COMPUTE1="52:54:00:ae:1d:04"
MAC_COMPUTE2="52:54:00:ae:1d:05"

BASE_NAME="osp"

#Create the controller node1
virsh destroy controller-lab1
virsh undefine controller-lab1
virt-install $MISC_OPTS $BOOT_OPTS $GRAPHICS_OPTS $RESOURCES_OPTS $CPU_OPTS $CONTROLLER_OPTS $DISK_1 $DISK_2 $DISK_3 $NETWORK_1$MAC_CONTROLLER1 $NETWORK_2$MAC_CONTROLLER1 $NETWORK_3$MAC_CONTROLLER1 --name=$BASE_NAME-controller1 > $BASE_NAME-controller1
virsh define controller-lab1

#Create the controller node2
virsh destroy controller-lab2
virsh undefine controller-lab2
virt-install $MISC_OPTS $BOOT_OPTS $GRAPHICS_OPTS $RESOURCES_OPTS $CPU_OPTS $CONTROLLER_OPTS $DISK_1 $DISK_2 $DISK_3 $NETWORK_1$MAC_CONTROLLER2 $NETWORK_2$MAC_CONTROLLER2 $NETWORK_3$MAC_CONTROLLER2 --name=$BASE_NAME-controller2 > $BASE_NAME-controller2
virsh define controller-lab2

#Create the controller node3
virsh destroy controller-lab3
virsh undefine controller-lab3
virt-install $MISC_OPTS $BOOT_OPTS $GRAPHICS_OPTS $RESOURCES_OPTS $CPU_OPTS $CONTROLLER_OPTS $DISK_1 $DISK_2 $DISK_3 $NETWORK_1$MAC_CONTROLLER3 $NETWORK_2$MAC_CONTROLLER3  $NETWORK_3$MAC_CONTROLLER3 --name=$BASE_NAME-controller3 > $BASE_NAME-controller3
virsh define controller-lab3

#Create the compute node1
virsh destroy compute-lab1
virsh undefine compute-lab1
virt-install $MISC_OPTS $BOOT_OPTS $GRAPHICS_OPTS $RESOURCES_OPTS $CPU_OPTS $CONTROLLER_OPTS $DISK_1 $DISK_2 $DISK_3 $NETWORK_1$MAC_COMPUTE1 $NETWORK_2$MAC_COMPUTE1 $NETWORK_3$MAC_COMPUTE1 --name=$BASE_NAME-compute1 > $BASE_NAME-compute1
virsh define compute-lab1

#Create the compute node2
virsh destroy compute-lab2
virsh undefine compute-lab2
virt-install $MISC_OPTS $BOOT_OPTS $GRAPHICS_OPTS $RESOURCES_OPTS $CPU_OPTS $CONTROLLER_OPTS $DISK_1 $DISK_2 $DISK_3 $NETWORK_1S$MAC_COMPUTE2 $NETWORK_2$MAC_COMPUTE2  $NETWORK_3$MAC_COMPUTE2 --name=$BASE_NAME-compute2 > $BASE_NAME-compute2
virsh define compute-lab2
