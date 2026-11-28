k run nginx --image=nginx:1.27 $do > pod.yaml
k run secure --image=nginx:1.27 $do > pod.yaml
k expose pod nginx --port=80 $do > svc.yaml
k create sa my-sa $do > sa.yaml
k create role pod-reader --verb=get,list --resource=pods $do > role.yaml
k create secret generic my-secret --from-literal=pass=s3cret $do > secret.yaml
