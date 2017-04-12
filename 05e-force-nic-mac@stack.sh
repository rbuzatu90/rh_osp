#!/bin/bash
NewTemplates=/home/stack/new_templates
cat >> $NewTemplates/infra-env.yaml <<EOF

parameter_defaults:
  NetConfigDataLookup:
    node1:
      nic1: "1c:98:ec:27:6e:b8"
      nic2: "58:20:b1:ea:1f:b8"
      nic3: "58:20:b1:ea:1f:bc"
    node2:
      nic1: "1c:98:ec:28:18:44"
      nic2: "58:20:b1:ea:1f:68"
      nic3: "58:20:b1:ea:1f:6c"
EOF
