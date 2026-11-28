k get networkpolicy -n 
k describe networkpolicy  -n 

#test connectivity

k exec  -- wget -qO- --timeout=2 http://:
k exec  -- nc -zv  

default deny all

cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
name: deny-all
namespace: 
spec:
podSelector: {}
policyTypes:

Ingress

Egress
EOF
