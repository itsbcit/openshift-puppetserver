[ -d /opt/puppetlabs/server/data ] || tar zxf /opt/puppetlabs/server.tar.gz -C /opt/puppetlabs
[ -f /opt/puppetlabs/server.tar.gz ] && rm -f /opt/puppetlabs/server.tar.gz
[ -d /opt/puppetlabs/server/data/puppetserver/.puppetlabs ] && rm -rf /opt/puppetlabs/server/data/puppetserver/.puppetlabs
mkdir -p /opt/puppetlabs/server/data/puppetserver/.puppetlabs/etc
ln -sf /etc/puppetlabs/puppet /opt/puppetlabs/server/data/puppetserver/.puppetlabs/etc/puppet

