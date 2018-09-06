if [ "$RUNUSER" = "puppet" ];then
    sed -i -r "s/^puppet:x:[0-9]+:[0-9]+:/puppet:x:${UID}:0:/" /etc/passwd
fi
