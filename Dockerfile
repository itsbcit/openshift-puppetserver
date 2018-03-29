FROM bcit/centos:7

ENV HOME /opt/puppetlabs/server/data/puppetserver
ENV RUNUSER puppet

RUN yum -y install https://yum.puppet.com/puppet/puppet5-release-el-7.noarch.rpm \
 && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5 \
 && yum -y install \
        puppetdb-termini \
        puppetserver

COPY puppetdb.conf /etc/puppetlabs/puppet/puppetdb.conf

COPY 10-resolve-userid.sh /docker-entrypoint.d/10-resolve-userid.sh

RUN find /opt/puppetlabs -type d -uid 999 \
  | xargs -I % \
    sh -c 'chown 0:0 %; chmod g+rwx %'

RUN chmod 775 /etc/puppetlabs \
 && find /etc/puppetlabs -type d -uid 999 \
  | xargs -I % \
    sh -c 'chown 0:0 %; chmod g+rwx %'

# Logging config
RUN rm -rf /var/log/puppetlabs \
 && chmod 775 /var/log
COPY 50-varlog.sh /docker-entrypoint.d/50-varlog.sh
COPY logback.xml /etc/puppetlabs/puppetserver/logback.xml
COPY request-logging.xml /etc/puppetlabs/puppetserver/request-logging.xml

RUN mkdir /etc/puppetlabs/ssl \
 && chown 0:0 /etc/puppetlabs/ssl \
 && chmod 770 /etc/puppetlabs/ssl 
VOLUME /etc/puppetlabs/ssl

RUN chown 0:0 /etc/puppetlabs/code \
 && chmod 775 /etc/puppetlabs/code
VOLUME /etc/puppetlabs/code

RUN mv /opt/puppetlabs/server/data /opt/puppetlabs/server/skel-data \
 && mkdir /opt/puppetlabs/server/data \
 && chown 0:0 /opt/puppetlabs/server/data \
 && chmod 775 /opt/puppetlabs/server/data 
VOLUME /opt/puppetlabs/server/data

ADD 50-puppetserver-data.sh /docker-entrypoint.d/50-puppetserver-data.sh

COPY puppet.conf /etc/puppetlabs/puppet/puppet.conf
RUN chmod g+rw /etc/puppetlabs/puppet/puppet.conf

COPY puppetserver /etc/default/puppetserver
COPY foreground /opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground

RUN chmod 775 /opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground \
 && chmod 775 /etc

CMD [ "/opt/puppetlabs/bin/puppetserver", "foreground" ]
