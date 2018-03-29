if [ "$RUNUSER" = "puppet" ];then
    sed -i "s/puppet:x:999:998/puppet:x:${UID}:0/" /etc/passwd
    sed -i "s/puppet:x:998:/puppet:x:998:puppet/" /etc/group
fi
