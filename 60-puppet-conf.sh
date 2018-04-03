sed -i "s/%CERTNAME%/${PUPPET_CERTNAME}/" /etc/puppetlabs/puppet/puppet.conf
sed -i "s/%ALTNAMES%/${PUPPET_CERT_ALTNAMES}/" /etc/puppetlabs/puppet/puppet.conf
