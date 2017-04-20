#!/bin/bash
cat << EOF >> ctlplane.xml

<network connections='1'>
  <name>ctlplane</name>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:ae:19:d2'/>
</network>

EOF

virsh net-define ctlplane.xml
virsh net-autostart ctlplane
virsh start ctlplane
