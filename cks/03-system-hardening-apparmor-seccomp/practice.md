# Domain 3 Practice Scenarios & Mock Questions

## Scenario 7 & Mock Q09 Seccomp + AppArmor Profile on a Pod
**Task (Q09)** Context `k8s-cluster2`. Create a pod named `seccomp-nginx` using `nginx:1.27` that enforces the `RuntimeDefault` Seccomp profile and a `Localhost` AppArmor profile named `k8s-nginx` (already loaded on all nodes).

**Key Takeaway:** Since Kubernetes v1.30+ (GA in v1.34), AppArmor is configured via `securityContext.appArmorProfile` rather than legacy annotations.

```bash
k config use-context k8s-cluster2
# Optional: verify profile is loaded on node
# ssh <node-name> -- sudo aa-status | grep k8s-nginx


apiVersion: v1
kind: Pod
metadata:
  name: seccomp-nginx
spec:
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: nginx
    image: nginx:1.27
    securityContext:
      appArmorProfile:
        type: Localhost
        localhostProfile: k8s-nginx


#Verify
k apply -f pod.yaml
k get pod seccomp-nginx # Must be Running
k get pod seccomp-nginx -o jsonpath='{.spec.containers[0].securityContext.appArmorProfile}'
