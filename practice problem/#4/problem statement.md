```powershell
Question No: 4
SIMULATION
You can switch the cluster/configuration context using the following command:
[desk@cli] $ kubectl config use-context qa

Context:
A pod fails to run because of an incorrectly specified ServiceAccount

Task:
Create a new service account named backend-qa in an existing namespace qa, which must not have access to any secret.
Edit the frontend pod yaml to use backend-qa service account
Note: You can find the frontend pod yaml at /home/cert_masters/frontend-pod.yaml
```
