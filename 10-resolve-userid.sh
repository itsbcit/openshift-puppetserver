if [ "$RUNUSER" = "puppet" ];then
    sed -i "s/^puppet:.*/puppet:x:${UID}:0/" /etc/passwd
    sed -i "s/^puppet:.*/puppet:x:998:puppet/" /etc/group
fi
