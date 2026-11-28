# Domain 1 Practice Scenarios & Mock Questions

## Scenario 1 NetworkPolicy — Default Deny & Targeted Allow
**Task** In namespace `production`, block all ingress and egress traffic by default. Allow pods with `app=frontend` to reach `app=api` on TCP `8080`, and ensure DNS resolution works.

**Key Takeaway** Applying any `NetworkPolicy` isolates the pod. Once `Egress` is restricted, you must explicitly allow `UDP 53` for DNS lookups.

```yaml
# netpol.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to: []
    ports:
    - protocol: UDP
      port: 53
