kubectl config use-context dev


k apply -f /home/cert_masters/network-policy.yaml

k describe netpol deny-network -n test

WEB_IP=$(k get pod web -n test -o jsonpath='{.status.podIP}')


k exec -n test client -- wget -T 3 -qO- http://$WEB_IP
