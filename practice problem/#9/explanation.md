# Auditing Pod Immutability & SecurityContext (`readOnlyRootFilesystem` & `privileged`)

## Walkthrough & Command Breakdown

### Checklist

- [ ] Inspect **`privileged`** and **`readOnlyRootFilesystem`** at a glance using **`custom-columns`**
- [ ] Remember `readOnlyRootFilesystem` defaults to `false` → anything not explicitly set to `true` must be deleted
- [ ] Remember `privileged` defaults to `false` → only Pods explicitly set to `true` must be deleted
- [ ] For multi-container Pods *(Sidecar Pattern)*, **every** container inside the Pod must satisfy both conditions

<br>

### Core Constraints

This scenario tests your ability to audit running workloads for runtime immutability (preventing tampering) and statelessness (no local writes inside the container).

- **Condition 1 (Stateless)** — Containers must not be able to write data to their local filesystem → **`readOnlyRootFilesystem: true`** is mandatory
- **Condition 2 (No Privileged)** — Containers must not run in privileged mode → **`privileged: true`** is forbidden (must be unset or `false`)

<br>

---

<br>

### Step 1 — Switch Cluster Context

```bash
kubectl config use-context immutable-cluster
```

- Mandatory in the real exam environment.

<br>

---

<br>

### Step 2 — Inspect SecurityContexts Across the `prod` Namespace

#### Approach 1 — Using `custom-columns` (Fastest & Cleanest)

```bash
k get pods -n prod -o custom-columns=NAME:.metadata.name,PRIVILEGED:.spec.containers[*].securityContext.privileged,READONLY_FS:.spec.containers[*].securityContext.readOnlyRootFilesystem
```

- Instead of wasting time opening `k get pod <Name> -o yaml` one by one, dumping everything into a clean table lets you spot the violators in 5 seconds with zero mistakes.
- **Example output**
<img width="1027" height="121" alt="image" src="https://github.com/user-attachments/assets/3740adf4-1462-4ed4-aafa-478f588f0642" />

<br>

#### Approach 2 — Using `grep` (Fallback)

```bash
k get pod -n prod -o yaml | grep -iE 'name:|privileged|readOnlyRootFilesystem'
```

- If you blank on the `custom-columns` JSONPath syntax during the exam, this quick `grep` gets you the exact same info.
- **Example output**
<img width="910" height="750" alt="image" src="https://github.com/user-attachments/assets/4a18989b-2328-403d-b283-6e44a47eedc0" />

<br>

---

<br>

### Step 3 — Identify & Delete Non-Compliant Pods

```bash
k delete pod cms nginx -n prod
```

- **`cms`**
  - **`READONLY_FS`** is `false`
  - → Can write to the internal filesystem → **Delete**

- **`nginx`**
  - **`PRIVILEGED`** is **`true`** and **`READONLY_FS`** is `<none>`
  - → Violates both conditions → **Delete**

- **`db`**
  - **`PRIVILEGED`** is `<none>` (`false`) and **`READONLY_FS`** is `true`
  - → Fully compliant → **Keep**

- **Example output**
<img width="500" height="70" alt="image" src="https://github.com/user-attachments/assets/66e4e64d-4024-44a9-a28c-653ac13f9fa6" />

<br>

---

<br>

### Step 4 — Final Verification

```bash
k get pods -n prod
```

- **Verification**
  - Once only the single `db` Pod remains in a `Running` state, you're done.

- **Example output**
<img width="402" height="80" alt="image" src="https://github.com/user-attachments/assets/29b498f2-603f-4bff-85d4-83ad6e8ae403" />

<br>

---

<br>

### ⚠️ What Happens If You Write It Wrong? (Classic Footguns)

- **Assuming a Pod with `readOnlyRootFilesystem` as `<none>` (unset) is safe**
  - In Kubernetes, **`readOnlyRootFilesystem`** defaults to **`false`**.
  - If the field is completely omitted, the container can write to its root filesystem—meaning it's a violator and **must be deleted**.

<br>

- **Deleting a Pod where `privileged` is `<none>`**
  - **`privileged`** defaults to **`false`**.
  - Seeing `<none>` here means it is unprivileged and safe—do **not** delete it for that.

<br>

- **Missing violations in multi-container Pods (Sidecar Pattern)**
  - When querying with **`containers[*]`**, multi-container Pods output comma-separated values like `true,false`.
  - If even a **single** container inside the Pod has **`privileged: true`** or lacks **`readOnlyRootFilesystem: true`**, the entire Pod is non-compliant and must be deleted.
