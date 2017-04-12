#!/bin/bash
NewTemplates=/home/stack/new_templates

cat << EOF >>$NewTemplates/post-deploy.yaml
   deploy-NTP:
     type: OS::Heat::SoftwareConfig
     properties:
       group: script
       config: |
         #!/bin/bash -x

         CTRLs=$(sudo os-apply-config --key hosts --type raw|awk '/CONTROL/{print $1}')
         case "$(hostname)" in
             ###### Gestion du NTP a partir des controleurs#####
             sudo sed -i 's/server .*//g' /etc/ntp.conf 
             for i in $CTRLs
             do
               echo server $i |sudo tee -a /etc/ntp.conf
             done
             sudo systemctl restart ntpd
             ;;
           *control*)
             ###### Gestion du NTP server #####
             sudo sed -i 's/restrict 192.168.205//g' /etc/ntp.conf
             echo 'restrict 192.168.205.0 mask 255.255.255.192'|sudo tee -a /etc/ntp.conf
             sudo systemctl restart ntpd
             ;;
           *ceph*)
             ###### Gestion du NTP a partir des controleurs#####
             sudo sed -i 's/server .*//g' /etc/ntp.conf 
             for i in $CTRLs
             do
               echo server $i |sudo tee -a /etc/ntp.conf
             done
             sudo systemctl restart ntpd
             ;;
         esac
   config_NTP:
     type: OS::Heat::SoftwareDeployments
     properties:
       servers: {get_param: servers}
       config: {get_resource: deploy-NTP}
       actions: ['CREATE','UPDATE']

EOF
