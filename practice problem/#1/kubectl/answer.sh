grep falco /var/log/syslog | grep "/dev/mem"

docker ps| grep ollama

kubectl get pod ollama-7b5689 -o wide --show-labels

kubectl get deployment -l app=ollama

kubectl pod ollama-7b5689 -o jsonpath='{.metadata.ownerReferences[0].name}'

kubectl deployment ollama --replicas=0

kubectl get pods | grep ollama
