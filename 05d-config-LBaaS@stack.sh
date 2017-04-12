#!/bin/bash
NewTemplates=/home/stack/new_templates
cat << EOF >>$NewTemplates/post-deploy.yaml
   deploy-:LBaaS
     type: OS::Heat::SoftwareConfig
     properties:
       group: script
       config: |
         #!/bin/bash -x
           sudo openstack-config --set /etc/neutron/neutron_lbaas.conf service_providers service_provider 'LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default'
           sudo openstack-config --set /etc/neutron/neutron.conf DEFAULT service_plugins 'router,qos,lbaas'
           sudo systemctl restart neutron-server.service
           sudo sed -i "s/'enable_lb': False,/'enable_lb': True,/g" /etc/openstack-dashboard/local_settings
           sudo systemctl restart httpd.service
           sudo openstack-config --set /etc/neutron/lbaas_agent.ini DEFAULT device_driver 'neutron_lbaas.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver'
           sudo openstack-config --set /etc/neutron/lbaas_agent.ini haproxy user_group 'haproxy'
           sudo openstack-config --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver 'neutron.agent.linux.interface.OVSInterfaceDriver'
           sudo systemctl restart neutron-lbaas-agent.service
           sudo systemctl enable neutron-lbaas-agent.service

   config_LBaaS:
     type: OS::Heat::SoftwareDeployments
     properties:
       servers: {get_param: controller_servers}
       config: {get_resource: deploy-LBaaS}
       actions: ['CREATE','UPDATE']

EOF
