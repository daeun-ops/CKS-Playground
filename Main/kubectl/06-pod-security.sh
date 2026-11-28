#check securityContext

k get pod  -o jsonpath='{.spec.securityContext}'
k get pod  -o jsonpath='{.spec.containers[*].securityContext}'

#psa labels

k label ns  pod-security.kubernetes.io/enforce=restricted
k label ns  pod-security.kubernetes.io/audit=restricted
k label ns  pod-security.kubernetes.io/warn=restricted

k get ns  --show-labels
