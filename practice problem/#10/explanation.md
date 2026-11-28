# Comprehensive CKS Review — End-to-End Security Hardening

## Walkthrough & Command Breakdown

- **Exam Domain** — Full CKS Syllabus Review (Scenarios 1–9 combined)
- **Objective** — Practice all 8 core security techniques from Scenarios 1–9 seamlessly inside a single, exam-style scenario

<br>

### Checklist

- [ ] **Task 1** — Scale `rogue-deploy` down to `replicas=0` without deleting the Deployment
- [ ] **Task 2** — Run Trivy scans, delete only **`legacy-web`**, and keep `clean-app` running
- [ ] **Task 3** — Verify the `default-deny-all` NetworkPolicy is applied
- [ ] **Task 4** — Verify the `enforce=baseline` PSA label on the `secure-app` namespace
- [ ] **Task 5** — Verify `app-auditor` SA permissions via `auth can-i` (`get`/`list` only → `yes`)
- [ ] **Task 6** — Verify the `sandbox-rc` RuntimeClass (`node.k8s.io/v1`, `runsc`)
- [ ] **Task 7** — Verify Dockerfile fixes (`ADD` → `COPY`, `USER root` → `USER nobody`)
- [ ] **Task 8** — Verify **`api-pod`** is `Running` with **`app-auditor`**, **`privileged` `false`**, **`readOnlyRootFilesystem` `true`**, and **`runAsUser` `1000`**

<br>

---

<br>

### Task 1 — Scale Down the Rogue Deployment

```bash
k scale deploy rogue-deploy -n secure-app --replicas=0
```

- **Verification**

```bash
k get deploy rogue-deploy -n secure-app
```

- **Example output**
  - Confirm `k get deploy rogue-deploy -n secure-app` shows `READY 0/0`
  - <img width="711" height="117" alt="image" src="https://github.com/user-attachments/assets/ef5c2c35-54f2-4d71-8c14-f7b01e10b2bb" />


<br>

---

<br>

### Task 2 — Scan Images with Trivy & Delete the Vulnerable Pod

1. **List running images**

```bash
k get pods -n secure-app -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[*].image
```

- **Example output**
  - <img width="1066" height="96" alt="image" src="https://github.com/user-attachments/assets/d83a1e96-d41a-4052-971f-575f48ddfee8" />


<br>

2. **Run Trivy vulnerability scans**

```bash
trivy image --severity HIGH,CRITICAL nginx:1.14.0
trivy image --severity HIGH,CRITICAL alpine:3.18
```

- **Example output**
  - <img width="1042" height="661" alt="image" src="https://github.com/user-attachments/assets/d20ac800-3452-4472-b251-158ac2f09eee" />
  - <img width="697" height="135" alt="image" src="https://github.com/user-attachments/assets/c43af283-5fe2-409f-af97-08e7babc6aab" />


<br>

3. **Delete `legacy-web` (flagged with multiple high/critical CVEs)**

```bash
k delete pod legacy-web -n secure-app
```

- **Verification**
  - Run `k get pods -n secure-app` → confirm **`legacy-web`** is gone and only **`clean-app`** remains
- **Example output**
  - <img width="565" height="122" alt="image" src="https://github.com/user-attachments/assets/bcf882b3-c3b5-400a-b9df-fff4419ee237" />


<br>

---

<br>

### Task 3 — Create a Default Deny NetworkPolicy

```bash
cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: secure-app
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
```

- **Example output**
  - <img width="514" height="288" alt="image" src="https://github.com/user-attachments/assets/10108d52-b072-407e-b811-b3e9cbf51bdc" />


<br>

- **Verification**

```bash
k describe netpol default-deny-all -n secure-app
```

  - Confirm **`PodSelector`** is `<none>` and **`Policy Types`** lists both **`Ingress`** and **`Egress`**
- **Example output**
  - <img width="805" height="291" alt="image" src="https://github.com/user-attachments/assets/82b48e60-777e-4c25-80b6-56151bbea293" />

<br>

---

<br>

### Task 4 — Enforce the PSA `baseline` Label

```bash
k label ns secure-app pod-security.kubernetes.io/enforce=baseline
```

- **Verification**

```bash
k get ns secure-app --show-labels
```

  - Confirm `pod-security.kubernetes.io/enforce=baseline` is attached to the namespace
- **Example output**
  - [이미지 - 캡쳐 까먹음 나중에 추가 예정 허허 샤갈]

<br>

---

<br>

### Task 5 — Configure ServiceAccount, Role, and RoleBinding

```bash
k create sa app-auditor -n secure-app
k create role pod-reader --verb=get,list --resource=pods -n secure-app
k create rolebinding app-auditor-binding \
  --role=pod-reader \
  --serviceaccount=secure-app:app-auditor \
  -n secure-app
```

- **Example output**
  - <img width="712" height="210" alt="image" src="https://github.com/user-attachments/assets/ccd780fa-53e3-465e-b87e-96fd84bf721e" />


<br>

- **Verification**

```bash
k auth can-i list pods --as=system:serviceaccount:secure-app:app-auditor -n secure-app   # yes
k auth can-i delete pods --as=system:serviceaccount:secure-app:app-auditor -n secure-app # no
```

- **Example output**
  - <img width="1092" height="95" alt="image" src="https://github.com/user-attachments/assets/2d4f0e22-46dd-4fe5-8c88-8e50a247585a" />


<br>

---

<br>

### Task 6 — Create the RuntimeClass

```bash
cat <<EOF | k apply -f -
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: sandbox-rc
handler: runsc
EOF
```

- **Example output**
  - <img width="417" height="185" alt="image" src="https://github.com/user-attachments/assets/861f8cf7-ef82-4e6e-aa16-eb8d6cf59222" />


<br>

- **Verification**

```bash
k get runtimeclass sandbox-rc
```

  - Confirm **`HANDLER`** is set to **`runsc`**
- **Example output**
  - <img width="470" height="62" alt="image" src="https://github.com/user-attachments/assets/67878087-268e-4b17-8bd8-f1d1fbd63e1c" />


<br>

---

<br>

### Task 7 — Patch Two Dockerfile Vulnerabilities

```bash
cat <<EOF > /home/candidate/review/Dockerfile
FROM ubuntu:16.04
COPY config.tar.gz /etc/app/
USER nobody
CMD ["sleep", "3600"]
EOF
```

- Swap `ADD` → `COPY`
- Swap `USER root` → `USER nobody` (or `1000`)
- Leave **`FROM ubuntu:16.04`** untouched

<br>

- **Verification**

```bash
cat /home/candidate/review/Dockerfile
```

- **Example output**
  - <img width="626" height="271" alt="image" src="https://github.com/user-attachments/assets/24d2f409-33d3-484f-a579-3bd5215fd84e" />


<br>

---

<br>

### Task 8 — Harden & Deploy the Pod Manifest

```bash
cat <<EOF > /home/candidate/review/api-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  namespace: secure-app
spec:
  serviceAccountName: app-auditor
  containers:
  - name: api
    image: busybox
    command: ["sleep", "3600"]
    securityContext:
      privileged: false
      readOnlyRootFilesystem: true
      runAsUser: 1000
EOF

k apply -f /home/candidate/review/api-pod.yaml
```

- **Example output**
  - <img width="637" height="427" alt="image" src="https://github.com/user-attachments/assets/f93af51a-54cb-4357-8a47-4056e8e9df22" />


<br>

- **Verification (Check both security attributes and `Running` status)**

```bash
k get pod api-pod -n secure-app
k get pod api-pod -n secure-app -o custom-columns=SA:.spec.serviceAccountName,PRIV:.spec.containers[*].securityContext.privileged,RO_FS:.spec.containers[*].securityContext.readOnlyRootFilesystem,UID:.spec.containers[*].securityContext.runAsUser
```

  - Once **`api-pod`** clears the PSA `baseline` policy, reaches `Running`, and outputs **`app-auditor`** / `false` / **`true`** / `1000`, you've officially completed the full Scenarios 1–9 review!
- **Example output**
  - <img width="912" height="182" alt="image" src="https://github.com/user-attachments/assets/addccd5c-e329-4201-97d1-53e4671608e5" />

