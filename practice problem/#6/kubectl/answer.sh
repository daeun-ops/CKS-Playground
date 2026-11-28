k apply -f gvisor-rc.yaml

k apply -f nginx-gvisor.yaml

k get runtimeclass

k get pod nginx-gvisor -n server -o jsonpath='{.spec.runtimeClassName}'; echo
