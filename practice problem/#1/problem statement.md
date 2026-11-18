```
Question No: 1
SIMULATION
Documentation Deployments, Pods, Falco

You must connect to the correct host. Failure to do so may result in a zero score.
[candidate@base] $ ssh cks000026

Context
A Pod is misbehaving and poses a security threat to the system.

Task
One of the Pods belonging to the application ollama is misbehaving. It is directly accessing the system's memory reading from the sensitive file /dev/mem.
First, identify the misbehaving Pod accessing /dev/mem.
The cluster uses the Docker Engine as its container runtime. If needed, use the docker command to troubleshoot running containers.
Next, identify the Deployment managing the misbehaving Pod and scale it to zero replicas.
Do not modify the Deployment except for scaling it down.
Do not modify any other Deployments.
Do not delete any Deployments.
```
