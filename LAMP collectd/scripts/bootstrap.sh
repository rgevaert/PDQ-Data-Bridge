#!/bin/bash

# Install puppet and r10k
[ -x /opt/puppetlabs/bin/puppet ] || apt-get install -y puppet-agent
[ -x /opt/puppetlabs/puppet/bin/r10k ] || /opt/puppetlabs/puppet/bin/gem install r10k

# Download/update modules
cd /vagrant && /opt/puppetlabs/puppet/bin/r10k puppetfile install
