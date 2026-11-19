```yaml
Question No: 8
You can switch the cluster/configuration context using the following command:
[desk@cli] $ kubectl config use-context stage

Context:
A PodSecurityPolicy shall prevent the creation of privileged Pods in a specific namespace.

Task:
1. Create a new PodSecurityPolicy named deny-policy, which prevents the creation of privileged Pods.
2. Create a new ClusterRole named deny-access-role, which uses the newly created PodSecurityPolicy deny-policy.
3. Create a new ServiceAccount named psp-denial-sa in the existing namespace development.
Finally, create a new ClusterRoleBinding named restrict-access-bind, which binds the newly created ClusterRole deny-access-role to the newly created ServiceAccount psp-denial-sa.
```
