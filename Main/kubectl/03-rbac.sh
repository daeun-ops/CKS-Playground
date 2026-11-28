k create sa my-sa -n my-ns
k create role pod-reader --verb=get,list,watch --resource=pods -n my-ns
k create rolebinding read-pods --role=pod-reader --serviceaccount=my-ns:my-sa -n my-ns

k create clusterrole node-reader --verb=get,list --resource=nodes
k create clusterrolebinding read-nodes --clusterrole=node-reader --serviceaccount=my-ns:my-sa

#check permissions

k auth can-i list pods -n my-ns --as=system:serviceaccount:my-ns:my-sa
k auth can-i get secrets --as=system:serviceaccount:default:default
k auth can-i '' '' --as=system:serviceaccount:kube-system:default
