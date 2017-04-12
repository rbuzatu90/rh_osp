#!/bin/bash
NewTemplates=/home/stack/new_templates
cat >> $NewTemplates/infra-env.yaml <<EOF

parameter_defaults:
  ExtraConfig:
    ceph::profile::params::osd_journal_size: 10210
    ceph::profile::params::osd_pool_default_pg_num: 200
    ceph::profile::params::osd_pool_default_pgp_num: 200
    ceph::profile::params::osds:
      /dev/sdd:
        journal: /dev/sdb
EOF
