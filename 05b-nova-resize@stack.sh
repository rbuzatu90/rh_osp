#!/bin/bash
NewTemplates=/home/stack/new_templates

cat << EOF >>$NewTemplates/postdeploy.yaml

  deploy-resize:
    type: OS::Heat::SoftwareConfig
    properties:
      group: script
      config: |
        #!/bin/bash -x
        NOVA_DIR=/var/lib/nova/.ssh
        PRIV="-----BEGIN RSA PRIVATE KEY-----\n
            "Content here"
        -----END RSA PRIVATE KEY-----\n
        "
        PUB="ssh-rsa public here" 

        CTRLs=\$(sudo os-apply-config --key hosts --type raw|awk '/CONTROL/{print $1}')
        case "\$(hostname)" in
          *compute*)
            ###### Gestion du resize local #####
            sudo openstack-config --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host True
            sudo openstack-config --set /etc/nova/nova.conf DEFAULT resize_confirm_window 5
            sudo openstack-config --set /etc/nova/nova.conf DEFAULT scheduler_default_filters AllHostsFilter
            sudo systemctl restart openstack-nova-compute

            ###### Gestion du resize avec clefs SSH #####
            mkdir \$NOVA_DIR
            echo -e \$PUB |sudo tee \$NOVA_DIR/id_rsa.pub
            echo -e \$PRIV |sudo tee \$NOVA_DIR/id_rsa
            echo -e \$PUB |sudo tee \$NOVA_DIR/authorized_keys
            sudo chmod 600  \$NOVA_DIR/id_rsa
            sudo chown -R nova.nova  \$NOVA_DIR
            sudo usermod -s /bin/bash nova
            ssh-keyscan -t rsa \$(sudo os-apply-config --key hosts --type raw |awk '{print \$1}') |sudo tee -a /etc/ssh/ssh_known_hosts

            ;;
          *control*)
            sudo openstack-config --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host True
            sudo openstack-config --set /etc/nova/nova.conf DEFAULT resize_confirm_window 5
            sudo openstack-config --set /etc/nova/nova.conf DEFAULT scheduler_default_filters AllHostsFilter
            sudo pcs resource restart openstack-nova-api
            sudo pcs resource restart openstack-nova-scheduler

            ;;
          *ceph*)
            ;;
        esac

  ExtraDeployment:
   type: OS::Heat::SoftwareDeployments
   properties:
     servers: {get_param: servers}
     config: {get_resource: ExtraConfig}
     actions: ['CREATE','UPDATE']
EOF
