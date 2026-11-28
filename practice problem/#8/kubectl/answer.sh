k label ns development pod-security.kubernetes.io/enforce=baseline


k run test-priv -n development --image=nginx --overrides='{"spec":{"containers":[{"name":"test-priv","image":"nginx","securityContext":{"privileged":true}}]}}'


k get pods -n development
