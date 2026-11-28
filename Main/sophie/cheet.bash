alias k='kubectl'
alias kn='kubectl config set-context --current --namespace'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kgnetpol='kubectl get networkpolicy'
alias kgsa='kubectl get serviceaccount'
alias kgsec='kubectl get secrets'
export do='--dry-run=client -o yaml'
export now='--force --grace-period=0'

source <(kubectl completion bash)
complete -o default -F __start_kubectl k

cat <<'EOF' >> ~/.vimrc
set expandtab
set tabstop=2
set shiftwidth=2
set number
set autoindent
EOF

export ETCDCTL_API=3
