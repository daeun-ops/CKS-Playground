```
Question No: 2
SIMULATION
Cluster: scanner
Master node: controlplane
Worker node: worker1

You can switch the cluster/configuration context using the following command:
[desk@cli] $ kubectl config use-context scanner

Given:
You may use Trivy's documentation.

Task:
Use the Trivy open-source container scanner to detect images with severe vulnerabilities used by Pods in the namespace nato.
Look for images with High or Critical severity vulnerabilities and delete the Pods that use those images.
Trivy is pre-installed on the cluster's master node. Use cluster's master node to use Trivy.
```
