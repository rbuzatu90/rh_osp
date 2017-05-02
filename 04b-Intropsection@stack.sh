#!/bin/bash
. /home/stack/stackrc

echo '###### Clean UP nodes ######'********
for i in `openstack baremetal node list|grep "None"|awk '{print $2};'` 
do
	openstack baremetal node power off "$i"
	openstack baremetal node delete "$i"
done
openstack baremetal node list

echo '###### Add new nodes ######'*****
INSTACK=instack-new
VirshSRV=root@192.168.122.1
eval `ssh-agent -s`
ssh-add .ssh/id_rsa2
ssh-add .ssh/id_rsa
ssh-copy-id -o StrictHostKeyChecking=no $VirshSRV
scp $VirshSRV:.ssh/* .ssh

# Get all nodes from this deployment; should contain "osp" in name
for SRV in `virsh --connect qemu+ssh://$VirshSRV/system list --all| grep osp | cut -c8-38`
do
        # Get provisioning "cltplane" network interface
	i=$(virsh --connect qemu+ssh://$VirshSRV/system domiflist "$SRV" | grep ctlplane | awk '{print $5};'|head -1) 
        # Get the profile of the node, should end in "compute", "control" or "ceph-storage"
	prof=$(echo "$SRV" | grep -o "compute\|control\|ceph-storage")
echo "****** adding $SRV ($i) as $prof *********"
        INSTACKnode=$INSTACK-$SRV.json
	KEY=`cat ~/.ssh/id_rsa|sed 's/  //g;s/$/\\\\n/g;s/END RSA PRIVATE KEY-----.*/END RSA PRIVATE KEY-----/g'|tr -d '\n'`
	cat > ~/$INSTACKnode << EOF
{
    "nodes":[
        {
            "mac":[
		"$i"
            ],
            "name":"$SRV",
            "capabilities":"profile:$prof,boot_option:local",
            "pm_type":"pxe_ssh",
            "pm_user":"root",
	    "pm_password":"$KEY",
            "pm_addr":"192.168.122.1"
        }
    ]
}
EOF
	openstack baremetal import --json ~/$INSTACKnode
	#openstack baremetal node set --property root_device='{"name":"/dev/sda"}' $SRV
done
echo '###### Introspection ######'
ironic node-list
openstack baremetal configure boot

pause=10


function introspectByOne()
{
for UUID in $(ironic node-list|awk '/None/{print $2};')
do
	echo "**** starting $UUID *****"
	openstack baremetal node manage $UUID
	openstack overcloud node introspect  $UUID --provide
time	while [ $(openstack baremetal introspection status $UUID|awk '/finished/ {print $4;}') == "False" ] ; do echo "waiting $pause s to finish"; openstack baremetal introspection status $UUID; sleep $pause;done
done
}

function introspectBulk()
{
  echo "***** Starting BULK introspection *****"
  for node in $(openstack baremetal node list -f value -c UUID) ; do openstack baremetal node manage $node ; done
  time openstack overcloud node introspect  $UUID --provide --all-manageable 
}

introspectBulk
#introspectByOne

