```yaml
Question No: 9
You must complete this task on the following cluster/nodes:
Cluster: immutable-cluster
Master node: master1
Worker node: worker1

You can switch the cluster/configuration context using the following command:
[desk@cli] $ kubectl config use-context immutable-cluster

Context:
It is best practice to design containers to be stateless and immutable.

Task:
Inspect Pods running in namespace prod and delete any Pod that is either not stateless or not immutable.
Use the following strict interpretation of stateless and immutable:
1. Pods being able to store data inside containers must be treated as not stateless.
Note: You don't have to worry whether data is actually stored inside containers or not already.
2. Pods being configured to be privileged in any way must be treated as potentially not stateless or not immutable.
```
