# Domain 2 Practice Scenarios & Mock Questions

## Scenario 6 & Mock Q01 Least-Privilege RBAC
**Task (Q01)** Context `k8s-cluster1`. Create ServiceAccount `audit-sa` and Role `pod-viewer` (`get, list, watch` on `pods`) in namespace `security`. Bind them together.

**Key Takeaway** Always verify RBAC rules using `k auth can-i <verb> <resource> --as=system:serviceaccount:<ns>:<sa>` to confirm both allowed (`yes`) and denied (`no`) actions.

```bash
k config use-context k8s-cluster1
k create ns security
k create sa audit-sa -n security

k create role pod-viewer -n security \
  --verb=get,list,watch \
  --resource=pods

k create rolebinding pod-viewer-binding -n security \
  --role=pod-viewer \
  --serviceaccount=security:audit-sa

# Verify
k auth can-i list pods -n security --as=system:serviceaccount:security:audit-sa   # y
k auth can-i delete pods -n security --as=system:serviceaccount:security:audit-sa # n
