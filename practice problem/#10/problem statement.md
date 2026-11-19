```yaml
Question No: 10
SIMULATION

Context:
A security audit was performed on the namespace secure-app and several critical violations were discovered. You must remediate all security issues listed below.

Task:
1. [Runtime / Q1] A Deployment named rogue-deploy in namespace secure-app is exhibiting suspicious behavior. Scale it down to 0 replicas. Do not delete the Deployment.
2. [Supply Chain / Q2] Use Trivy to scan the images of Pods legacy-web and clean-app running in namespace secure-app. Delete any Pod whose image has HIGH or CRITICAL vulnerabilities.
3. [Network / Q3] Create a default-deny NetworkPolicy named default-deny-all in namespace secure-app that denies all Ingress and Egress traffic for all Pods in the namespace.
4. [PSA / Q8] Configure namespace secure-app with Pod Security Admission to enforce the baseline profile.
5. [RBAC / Q4, Q7] Create a ServiceAccount named app-auditor in namespace secure-app. Create a Role named pod-reader in namespace secure-app that allows only get and list verbs on pods. Bind this Role to app-auditor via a RoleBinding named app-auditor-binding.
6. [Sandboxing / Q6] Create a RuntimeClass named sandbox-rc using the handler runsc.
7. [Static Analysis / Q5] Fix two security issues in /home/candidate/review/Dockerfile (do not change the base image ubuntu:16.04).
8. [Hardening & Immutability / Q4, Q5, Q9] Edit /home/candidate/review/api-pod.yaml so that the Pod runs in namespace secure-app using ServiceAccount app-auditor, is NOT privileged, runs as user ID 1000, and has a read-only root filesystem. Then apply it.
```
