#!/bin/bash

echo "127.0.0.1 mco-client.example.com" > /etc/hosts
echo "$1	mco-katello.example.com" >> /etc/hosts
hostname mco-client.example.com

yum install -y 'http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm'
yum install -y puppet-3.7.5
cat > /etc/puppet/puppet.conf << EOF
[main]
vardir = /var/lib/puppet
logdir = /var/log/puppet
rundir = /var/run/puppet
ssldir = \$vardir/ssl

[agent]
pluginsync      = true
report          = true
ignoreschedules = true
daemon          = false
ca_server       = mco-katello.example.com
certname        = mco-client.example.com
environment     = production
server          = mco-katello.example.com
EOF

# register
puppet agent --test

# let's hope mcollective hostgroup_id is 1 (today I'm too tired to parse json in bash to find the real value :-)
curl "https://mco-katello.example.com/api/hosts/mco-client.example.com/?host\[hostgroup_id\]=1" --insecure --user 'admin:changeme' -X PUT

# we need old versions so the puppet module works
yum install mcollective-common-2.2.3 mcollective-2.2.3
puppet agent --onetime --verbose --no-daemonize

# let's install package agent on this mcollective server
yum install mcollective-package-agent
service mcollective restart
