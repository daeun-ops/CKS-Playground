```powershell
Question No: 3
SIMULATION
You can switch the cluster/configuration context using the following command:
[desk@cli] $ kubectl config use-context dev

A default-deny NetworkPolicy avoid to accidentally expose a Pod in a namespace that doesn't have any other NetworkPolicy defined.

Task:
Create a new default-deny NetworkPolicy named deny-network in the namespace test for all traffic of type Ingress + Egress
The new NetworkPolicy must deny all Ingress + Egress traffic in the namespace test.
Apply the newly created default-deny NetworkPolicy to all Pods running in namespace test.
You can find a skeleton manifests file at /home/cert_masters/network-policy.yaml
```
