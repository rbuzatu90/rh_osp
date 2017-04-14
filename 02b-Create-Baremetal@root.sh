#!/bin/bash

CPUOPTS="--cpu host"
GRAPHICS="--graphics vnc --video=cirrus"
CONTROLLER="--controller scsi,model=virtio-scsi,index=0"
DISKOPTS="format=qcow2,bus=scsi,cache=writeback"
VMBASE=/vms
RHEL_ISO=/var/lib/libvirt/images/rhel-server-7.2-x86_64-dvd.iso

# Create the director / undercloud node
virt-install --noautoconsole --print-xml --boot cdrom,hd,menu=on $GRAPHICS --ram 4096 --vcpus=2 $CPUOPTS $CONTROLLER --name=director --disk=path=$RHEL_ISO,device=cdrom  --disk=path=$VMBASE/director/director.qcow,size=40,$DISKOPTS --network=network=default,mac=52:54:00:63:0e:00,model=virtio > ~/director.xml

#Create the controller node
virt-install --noautoconsole --print-xml --boot cdrom,hd,menu=on $GRAPHICS --ram 4096 --vcpus=2 $CPUOPTS $CONTROLLER --name=controller --disk=path=$VMBASE/controller/controller.qcow,size=40,$DISKOPTS --network=network=default,mac=52:54:00:63:0e:01,model=virtio > ~/controller.xml

#Create the compute node
virt-install --noautoconsole --print-xml --boot network,hd,menu=on $GRAPHICS --ram 4096 --vcpus=2 $CPUOPTS $CONTROLLER --name=compute --disk=path=$VMBASE/compute/compute.qcow,size=40,$DISKOPTS --network=network=default,mac=52:54:00:63:0e:02,model=virtio > ~/compute.xml


virsh define ~/compute.xml
virsh define ~/director.xml
virsh define ~/controller.xml
