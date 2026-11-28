k create secret generic my-secret --from-literal=key=value -n my-ns
k create secret tls tls-secret --cert=tls.crt --key=tls.key

#decode secret

k get secret my-secret -o jsonpath='{.data.key}' | base64 -d

#verify encryption at rest

cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep encryption-provider-config
