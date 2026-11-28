# Blocking Privileged Pods with Pod Security Admission (PSA) & RBAC

## Walkthrough & Command Breakdown

### Pre-Flight Checklist
- [ ] PSP was removed in v1.25 → modern CKS exams test this using PSA Namespace labels
- [ ] Run `k label ns <Namespace> pod-security.kubernetes.io/enforce=baseline` (or `restricted`)
- [ ] Run a two-way verification — attempt to create a violating Pod (`Forbidden`) and a normal Pod (`created`)
- [ ] Remember that `resourceNames` in a `ClusterRole` scopes permissions down to specific named resources

<br>

### Core Constraints
The goal here is to block the creation of privileged (`privileged: true`) containers.

- **Critical Version Change** — PodSecurityPolicy (PSP) was completely removed in Kubernetes v1.25. On current CKS exams, it has been replaced by Namespace label-based **PSA (Pod Security Admission)**.
- Because of this, you should practice the modern PSA approach on Killercoda (latest K8s), while still keeping the legacy dump's RBAC (`ClusterRole` + `ClusterRoleBinding`) syntax sharp.

---

<br>

### Step 1 — Block Privileged Pods Using a PSA Label

```bash
k label ns development pod-security.kubernetes.io/enforce=baseline
```

- Enforces the `baseline` security policy on the `development` namespace.
- **What this does**
  - Forces every Pod created inside the namespace to comply with Kubernetes' `baseline` Pod Security Standard.

#### Understanding the 3 PSA Profiles
- **`privileged`** — Unrestricted (default).
- **`baseline`** — Blocks known privilege escalations like `privileged: true`, `hostNetwork`, and `hostPath`.
- **`restricted`** — Enforces the strictest hardening standards (`runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `seccompProfile`, etc.).

#### Understanding the 3 PSA Modes
- **`enforce`** — Immediately rejects creation of any violating Pod.
- **`audit`** — Allows creation, but logs the violation to the Audit Log.
- **`warn`** — Allows creation, but prints a warning message to the user's terminal.

- **Example output**
<img width="825" height="55" alt="image" src="https://github.com/user-attachments/assets/c9b5b6b1-f2a2-4cfe-9e99-2730ed60add3" />

---

<br>

### Step 2 — Verify PSA Enforcement

1. **Attempt to spin up a privileged Pod → Must fail with `Forbidden`**

```bash
k run test-priv -n development --image=nginx --overrides='{"spec":{"containers":[{"name":"test-priv","image":"nginx","securityContext":{"privileged":true}}]}}'
```

2. **Attempt to spin up a normal Pod → Must succeed (`created`)**

```bash
k get pods -n development
```

- **Verification**
  - `test-priv` gets blocked with a `violates PodSecurity "baseline:latest"` error, while `test-normal` comes up cleanly.
- **Example output**
<img width="1687" height="52" alt="image" src="https://github.com/user-attachments/assets/a2988123-db1e-4715-b084-3bfc16f5cad2" />
<img width="460" height="75" alt="image" src="https://github.com/user-attachments/assets/b9a08de5-5b8e-4468-a463-88c4d2bdd750" />

---

<br>

### Step 3 — Create the ServiceAccount, ClusterRole, and ClusterRoleBinding

- While the PSP resource itself will error out on modern clusters, you can still practice the RBAC portion (steps 2–4 of the prompt) as-is.

1. **Create the ServiceAccount**

```bash
k create sa psp-denial-sa -n development
```

- **Example output**
<img width="596" height="52" alt="image" src="https://github.com/user-attachments/assets/bc262256-e20a-4ce2-85ee-247d0d1fdb36" />

2. **Create a `ClusterRole` scoped to a specific `resourceNames` entry**

```bash
cat <<EOF | k apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: deny-access-role
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs: ['use']
  resourceNames:
  - 'deny-policy'
EOF
```

- **Example output**
<img width="582" height="290" alt="image" src="https://github.com/user-attachments/assets/f14d80b1-5c09-4a4d-b758-9863fc1ecba6" />

3. **Create the `ClusterRoleBinding`**

```bash
k create clusterrolebinding restrict-access-bind \
  --clusterrole=deny-access-role \
  --serviceaccount=development:psp-denial-sa
```

- **Example output**
<img width="696" height="100" alt="image" src="https://github.com/user-attachments/assets/b8b1bfe4-f822-4185-92c8-24e12c797e14" />

- **Verification**
  - Run `k describe clusterrolebinding restrict-access-bind` to confirm the Role and Subjects are wired up properly.

---

<br>

### ⚠️ What Happens If You Write It Wrong? (Classic Footguns)

- **Only applying `warn` or `audit` labels instead of `enforce`**
  - Privileged Pods won't be blocked—they'll spin right up. Whenever a prompt asks you to **"prevent"** something, you must use **`enforce`**.
- **Pre-existing privileged Pods**
  - Slapping a PSA label onto a namespace does **not** automatically kill Pods that are already running.
  - It only blocks newly created Pods, so if there are already violating Pods running, you have to delete them manually.
- **Omitting the namespace in `--serviceaccount` for `ClusterRoleBinding`**
  - Just like with `RoleBinding`, you must strictly follow the `<namespace>:<sa-name>` format (e.g., `development:psp-denial-sa`).
