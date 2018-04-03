if [ -w /etc/puppetlabs/puppet/puppet.conf ];then
    sed -i "s/%CERTNAME%/${PUPPET_CERTNAME}/" /etc/puppetlabs/puppet/puppet.conf
    sed -i "s/%ALTNAMES%/${PUPPET_CERT_ALTNAMES}/" /etc/puppetlabs/puppet/puppet.conf
    sed -i "s/%SERVERNAME%/${PUPPET_SERVERNAME}/" /etc/puppetlabs/puppet/puppet.conf
fi
