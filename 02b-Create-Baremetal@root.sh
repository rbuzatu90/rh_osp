#!/bin/bash

set -x

CPU_OPTS="--cpu host"
GRAPHICS_OPTS="--graphics vnc --video=cirrus"
CONTROLLER_OPTS="--controller scsi,model=virtio-scsi,index=0"
MISC_OPTS="--noautoconsole --print-xml --check path_in_use=no"
BOOT_OPTS="--boot network,hd,menu=on"
VMBASE=/vms
VMs="controller-os compute-os network-os"
RESOURCES_OPTS="--ram 4096 --vcpus=2"

# ctlplane no dhcp; mgm-net no dhcp but external with nat
NETWORK_1="--network=network=ctlplane,model=virtio"
NETWORK_2="--network=network=mgmt-net,model=virtio"
NETWORK_3="--network=network=mgmt-net,model=virtio"

DISK_1="--disk pool=storage-pool,size=40,format=qcow2,bus=scsi,cache=writeback"

BASE_NAME="osp"

VIRSH_BASE="virt-install $MISC_OPTS $BOOT_OPTS $GRAPHICS_OPTS $RESOURCES_OPTS $CPU_OPTS $CONTROLLER_OPTS $DISK_1 $NETWORK_1 $NETWORK_2 $NETWORK_3"

# Specify number of nodes for each role
CONTROLLER_COUNT=3
COMPUTE_COUNT=2
CEPH_COUNT=3

function create_vms() {
    ROLE=$1
    for INDEX in $(eval echo "{1..$COUNT}");do 
        $VIRSH_BASE --name $BASE_NAME-$ROLE$INDEX > $BASE_NAME-$ROLE$INDEX
    done
}

create_vms controller $CONTROLLER_COUNT
create_vms compute $COMPUTE_COUNT
# Uncomment if you want ceph nodes
#create_vms ceph $CEPH_COUNT


