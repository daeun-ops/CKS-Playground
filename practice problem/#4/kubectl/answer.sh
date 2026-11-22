
kubectl config use-context qa

k create sa backend-qa -n qa

k auth can-i get secrets --as=system:serviceaccount:qa:backend-qa -n qa

vi /home/cert_masters/frontend-pod.yaml

k replace --force -f /home/cert_masters/frontend-pod.yaml

k get pod frontend -n qa
k get pod frontend -n qa -o jsonpath='{.spec.serviceAccountName}'
