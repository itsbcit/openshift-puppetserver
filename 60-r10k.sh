[ -e $R10K_CONFIG ] || cat << EOF > $R10K_CONFIG
---
cachedir: '/var/lib/r10k/cache'
git:
  provider: 'shellgit'

EOF

[ -e $R10K_SSH_IDENTITY ] || ssh-keygen -q -N '' -f $R10K_SSH_IDENTITY
[ -e ${R10K_SSH_IDENTITY}.pub ] && cat ${R10K_SSH_IDENTITY}.pub

[ -e $HOME/.ssh ] || mkdir $HOME/.ssh
[ -e $HOME/.ssh/config ] || echo "StrictHostKeyChecking no" > $HOME/.ssh/config

cat $R10K_SSH_IDENTITY > $HOME/.ssh/id_rsa
chmod 400 $HOME/.ssh/id_rsa
