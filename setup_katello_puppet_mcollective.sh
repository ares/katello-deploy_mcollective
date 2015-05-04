#!/bin/sh

rm -rf /etc/puppet/environments/example_env/

pushd /etc/puppet/modules
puppet module install puppet-mcollective
#git clone https://github.com/puppet-community/puppet-mcollective mcollective

pushd ~
mkdir .hammer
echo "foreman:
  :host: 'https://localhost'
  :username: admin
  :password: changeme" > ~/.hammer/cli_config.yml

hammer environment update --organizations 'Default Organization' --locations 'Default Location' --name production

# api does not have support for setting
echo "*" > /etc/puppet/autosign.conf
# hammer does not have support
curl https://mco-katello.example.com//api/smart_proxies/1/import_puppetclasses --insecure --user 'admin:changeme' -X POST


hammer hostgroup create --name mcollective --organizations 'Default Organization' --locations 'Default Location' --environment production \
--puppet-proxy-id 1 --puppet-ca-proxy-id 1 --puppet-classes mcollective

hammer sc-param add-override-value --match hostgroup=mcollective --puppet-class mcollective --smart-class-parameter middleware_hosts --value ['mco-katello.example.com']
hammer sc-param add-override-value --match fqdn=mco-katello.example.com --puppet-class mcollective --smart-class-parameter middleware --value true
hammer sc-param add-override-value --match fqdn=mco-katello.example.com --puppet-class mcollective --smart-class-parameter client --value true

hammer host update --hostgroup mcollective --name mco-katello.example.com

service iptables stop
chkconfig iptables off
yum install activemq

# we need old versions so the puppet module works
yum install mcollective-common-2.2.3 mcollective-2.2.3 mcollective-client-2.2.3
puppet agent --onetime --verbose --no-daemonize

# let's install package plugin for client and agent for this mcollective server
yum install mcollective-package-client mcollective-package-agent
service mcollective restart
