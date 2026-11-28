#check apiserver flags

cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep audit

#filter audit logs

cat /var/log/kubernetes/audit/audit.log | jq .
tail -f /var/log/kubernetes/audit/audit.log | jq 'select(.verb=="create")'
cat /var/log/kubernetes/audit/audit.log | jq 'select(.user.username=="system:serviceaccount:default:default")'
