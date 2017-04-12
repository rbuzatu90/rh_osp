#!/bin/bashNewTemplates=/home/stack/new_templates
cat >> $NewTemplates/infra-env.yaml <<EOF

parameter_defaults:
  ControllerHostnameFormat: controller-%index%
  ComputeHostnameFormat: compute-%index%
  CephStorageHostnameFormat: ceph-%index%

  ControllerSchedulerHints:
    'capabilities:node': 'controller-%index%'

  NovaComputeSchedulerHints:
    'capabilities:node': 'compute-%index%'

  CephStorageSchedulerHints:
    'capabilities:node': 'ceph-%index%'

  HostnameMap:
#Contoller nodes
    controller-0: ycrta00
    controller-1: ycrta01

EOF

