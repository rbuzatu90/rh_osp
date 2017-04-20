#!/bin/bash
NewTemplates=/home/stack/new_templates
cat >> $NewTemplates/infra-env.yaml <<EOF
resource_registry:
  OS::TripleO::Controller::Ports::ExternalPort: /home/stack/templates/network/ports/external_from_pool.yaml
  OS::TripleO::Controller::Ports::ManagementPort: /home/stack/templates/network/ports/management_from_pool.yaml

  OS::TripleO::CephStorage::Ports::ManagementPort: /home/stack/templates/network/ports/management_from_pool.yaml

  OS::TripleO::Compute::Ports::ManagementPort: /home/stack/templates/network/ports/management_from_pool.yaml

parameter_defaults:
# VIP on one of the contollers 
  PublicVirtualFixedIPs: [{'ip_address':'10.99.153.10'}]

# Each controller will get an IP from the lists below, first controller, first IP
  ControllerIPs:
      external:
      - 10.99.153.11
      - 10.99.153.12
      - 10.99.153.13
      management:
      - 10.99.148.30
      - 10.99.148.29
      - 10.99.148.51

# Each ceph node will get an IP from the lists below, first node, first IP
  CephStorageIPs:
      management:
      - 10.99.148.33
      - 10.99.148.10
      - 10.99.148.32
EOF
