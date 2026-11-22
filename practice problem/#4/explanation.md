# Creating a ServiceAccount & Binding It to a Pod

## Walkthrough & Command Breakdown

### Checklist
- [ ] `k create sa backend-qa -n qa` (don't forget the namespace flag)
- [ ] `k auth can-i get secrets --as=system:serviceaccount:qa:backend-qa -n qa` → verify it returns `no`
- [ ] Update `serviceAccountName: backend-qa` inside the YAML manifest
- [ ] Run `k replace --force -f /home/cert_masters/frontend-pod.yaml` to force-recreate the Pod and verify it reaches `Running`

<br>

### Core Constraints
The Pod is currently failing to start because it's bound to the wrong ServiceAccount.  
Your objective is to create a brand-new ServiceAccount (`backend-qa`) in the `qa` namespace with zero access to Secrets, update the `frontend` Pod manifest to use it, and get the Pod up and running cleanly.

---

### Step 1 — Switch Cluster Context

```bash
kubectl config use-context qa
```

- Mandatory in the real exam environment.

---

<br>

### Step 2 — Create the New ServiceAccount & Verify Permissions

```bash
k create sa backend-qa -n qa
```

- **What this does**
  - Creates a new ServiceAccount named `backend-qa` inside the `qa` namespace.
- **Must not have access to any secret**
  - Kubernetes RBAC is strictly **Default Deny** (least privilege) out of the box.
  - As long as you don't bind any `Role` or `RoleBinding` to this fresh ServiceAccount, it has zero access to any resource—including Secrets.
- **Example output**
  - <img width="471" height="47" alt="image" src="https://github.com/user-attachments/assets/ca5dc3ff-2e32-48e6-9459-4a5d69540f7c" />

- **Verify permissions (`auth can-i`)**
  ```bash
  k auth can-i get secrets --as=system:serviceaccount:qa:backend-qa -n qa
  ```
  - If the output comes back as `no`, you've confirmed the ServiceAccount cannot read Secrets.
- **Example output**
  - <img width="862" height="45" alt="image" src="https://github.com/user-attachments/assets/28e38730-0131-44e9-bf63-25362d2df9d2" />

> 💡 **`automountServiceAccountToken`**  
> Depending on the prompt, the exam might also want you to block the SA token from being mounted inside the Pod altogether.  
> If the prompt explicitly forbids token mounting, add `automountServiceAccountToken: false` to either the ServiceAccount or the Pod spec.

---

<br>

### Step 3 — Update the `frontend` Pod YAML

```bash
vi /home/cert_masters/frontend-pod.yaml
```

- Change `spec.serviceAccountName` to `backend-qa` and save the file.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: qa
spec:
  serviceAccountName: backend-qa
  containers:
  - name: nginx
    image: nginx
```

---

<br>

### Step 4 — Create (or Recreate) the Pod & Verify

- Use `apply` if the Pod doesn't exist in the cluster yet; if it's already running, use `replace --force`.

```bash
k replace --force -f /home/cert_masters/frontend-pod.yaml
```

- **Example output**
  <img width="730" height="52" alt="image" src="https://github.com/user-attachments/assets/12803056-a5ae-416a-b439-bde392593b59" />

- **Confirm the Pod is `Running` and bound to the right SA**

```bash
k get pod frontend -n qa
k get pod frontend -n qa -o jsonpath='{.spec.serviceAccountName}'
```

- **Example output**
  - <img width="797" height="97" alt="image" src="https://github.com/user-attachments/assets/5b9f4fd9-d00a-4c46-97e1-01ae556a5a59" />

---

<br>

### ⚠️ What Happens If You Write It Wrong? (Classic Footguns)

- **Running `k apply -f` on a Pod that's already running**
  - A Pod's `serviceAccountName` is an **immutable** field. If you edit the SA on an existing Pod and run `k apply`, Kubernetes will reject it with a `Forbidden: pod updates may not change fields other than...` error.
  - You must tear down and recreate the Pod using `k replace --force -f` (or `k delete` followed by `k apply`).
- **Forgetting `-n qa` when running `k create sa backend-qa`**
  - That drops the ServiceAccount into the `default` namespace. Since a Pod can only reference a ServiceAccount living in its own namespace (`qa`), Pod creation will fail with `serviceaccount "backend-qa" not found`.
- **Using `serviceAccount` instead of `serviceAccountName`**
  - The `serviceAccount` field is deprecated.
  - Always stick to the official `serviceAccountName` field on the exam.
