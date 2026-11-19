kubectl get pods -n nato -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[*].image 


trivy image --severity HIGH,CRITICAL nginx:1.14.0
trivy image --severity HIGH,CRITICAL alpine:3.18


kubectl delete pod vulnerable-pod -n nato
