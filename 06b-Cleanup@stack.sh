#!/bin/bash
. /home/stack/stackrc

echo "Check all ironic node..."
 
#Shutdown node stay on
for node in $(ironic node-list | egrep "power on" | awk '{print $2}'); do
  echo "Switch $node to off"
  ironic node-set-power-state $node off
done
 
#Set provision state to available
for node in $(ironic node-list | grep -P "(active|wait|deploy|cleaning)" | awk '{print $2}'); do
  echo "Set $node in available state"
  ironic node-set-provision-state $node deleted
done
 
#Set provision state to available
for node in $(ironic node-list | grep manageable | awk '{print $2}'); do
  echo "Set $node in available state"
  ironic node-set-provision-state $node provide
done
 
#Unset instance_uuid param
for node in $(ironic node-list | awk '{print $2" "$6}' | grep -v -P '(None|Inst|^\s*$)'| awk '{print $1}'); do
  echo "Unset instance_uuid on $node"
  ironic node-update $node remove instance_uuid  > /dev/null
done
 
#Switch maintenance mode to false
for node in $(ironic node-list | grep "True" | awk '{print $2}'); do
  echo "Switch off maintenance mode on $node"
  ironic node-set-maintenance $node false
done
 
echo "Done."
