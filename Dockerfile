FROM bcit/centos:7
LABEL maintainer="jesse_weisner@bcit.ca"
LABEL puppetserver_version="6.6.0"
LABEL puppetdb_version="6.6.0"
LABEL vault_gem_version="0.12.0"
LABEL debouncer_gem_version="0.2.2"
LABEL r10k_gem_version="3.3.1"
LABEL build_id="1569001942"

ENV HOME=/opt/puppetlabs/server/data/puppetserver
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH
ENV RUNUSER=puppet
ENV PUPPET_HEALTHCHECK_ENVIRONMENT=production
ENV PUPPET_CERTNAME=puppetserver
ENV PUPPET_CERT_ALTNAMES="puppetserver.puppet.svc,puppetserver,puppet"
ENV PUPPET_SERVERNAME=puppetserver
ENV R10K_CONFIG=/etc/puppetlabs/r10k/r10k.yaml
ENV R10K_SSH_IDENTITY=/etc/puppetlabs/r10k/id-r10k
ENV PUPPETSERVER_JAVA_ARGS "-Xms2g -Xmx2g -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger"

RUN yum -y --setopt tsflags=nodocs --setopt timeout=5 install \
        https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm \
 && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet6-release \
 && yum -y --setopt tsflags=nodocs --setopt timeout=5 install \
        puppetdb-termini-6.6.0 \
        puppetserver-6.6.0 \
        git \
 && rm -rf /var/cache/yum

# assert that pupetserver is installed
RUN rpm -q puppetserver-6.6.0

RUN userdel puppet

COPY puppetdb.conf /etc/puppetlabs/puppet/puppetdb.conf

COPY 60-puppet-conf.sh /docker-entrypoint.d/60-puppet-conf.sh
COPY 60-r10k.sh /docker-entrypoint.d/60-r10k.sh

RUN chmod    775 /opt/puppetlabs \
 && chown -R 0:0 /opt/puppetlabs \
 && find /opt/puppetlabs -type d | xargs chmod g+rwx \
 && find /opt/puppetlabs -type f | xargs chmod g+rw

RUN chmod 775 /etc/puppetlabs \
 && find /etc/puppetlabs -type d \
  | xargs -I % \
    sh -c 'chown 0:0 %; chmod g+rwx %'

RUN chown 0:0 /etc/puppetlabs/code \
 && chmod 775 /etc/puppetlabs/code
VOLUME /etc/puppetlabs/code
COPY 50-production.sh /docker-entrypoint.d/50-production.sh

COPY puppetserver /etc/default/puppetserver
COPY foreground /opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground

RUN chmod 775 /opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground \
 && chmod 775 /etc

ADD 50-puppetserver-server.sh /docker-entrypoint.d/50-puppetserver-server.sh

COPY puppet.conf /etc/puppetlabs/puppet/puppet.conf
RUN chmod g+rw /etc/puppetlabs/puppet/puppet.conf

RUN /opt/puppetlabs/puppet/bin/gem install --no-rdoc --no-ri -v 3.3.1 r10k

RUN mkdir -p /var/lib/r10k && \
    chown 0:0 /var/lib/r10k && \
    chmod 1770 /var/lib/r10k
VOLUME /var/lib/r10k

RUN mkdir /etc/puppetlabs/r10k && \
    chown 0:0 /etc/puppetlabs/r10k && \
    chmod g+rwx /etc/puppetlabs/r10k
VOLUME /etc/puppetlabs/r10k

RUN /opt/puppetlabs/puppet/bin/gem install --no-rdoc --no-ri -v 0.12.0 vault
RUN /opt/puppetlabs/puppet/bin/gem install --no-rdoc --no-ri -v 0.2.2 debouncer
RUN /opt/puppetlabs/bin/puppetserver gem install --no-rdoc --no-ri -v 0.12.0 vault
RUN /opt/puppetlabs/bin/puppetserver gem install --no-rdoc --no-ri -v 0.2.2 debouncer

RUN tar czf /opt/puppetlabs/server.tar.gz -C /opt/puppetlabs server
RUN rm -rf /opt/puppetlabs/server \
 && chown 0:0 /opt/puppetlabs \
 && chmod 775 /opt/puppetlabs

ADD 60-skel.sh /docker-entrypoint.d/60-skel.sh

RUN rm -rf /var/log/puppetlabs \
 && mkdir /var/log/puppetlabs \
 && chown 0:0 /var/log/puppetlabs \
 && chmod 0770 /var/log/puppetlabs

VOLUME /var/log/puppetlabs

ADD healthcheck-puppetserver.sh /
RUN chmod 555 /healthcheck-puppetserver.sh

EXPOSE 8140

CMD [ "/opt/puppetlabs/bin/puppetserver", "foreground" ]
