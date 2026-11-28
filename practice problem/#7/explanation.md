# Cluster Hardening — Extracting a Pod's ServiceAccount & Applying Least-Privilege RBAC

## Walkthrough & Command Breakdown

###Checklist
- [ ] Run `k get pod nginx-pod -n test-system -o jsonpath='{.spec.serviceAccountName}'` and save **only** the raw SA name to `/candidate/KSC00124.txt`
- [ ] Run `k create role dev-test-role --verb=update --resource=namespaces -n test-system`
- [ ] Run `k create rolebinding dev-test-role-binding --role=dev-test-role --serviceaccount=test-system:<SA-Name> -n test-system` (`<Namespace>:<SA-Name>` format is mandatory)
- [ ] Run `k auth can-i update namespaces --as=system:serviceaccount:test-system:<SA-Name> -n test-system` → verify it returns `yes`

<br>

### Core Constraints
This is a classic Cluster Hardening scenario — inspect which ServiceAccount (SA) a specific Pod is running under, write it to a file, and bind **least-privilege RBAC** to that exact SA.

- Extract the ServiceAccount name used by **`nginx-pod`** in the `test-system` namespace and save it to **`/candidate/KSC00124.txt`**.
- Create a `Role` named `dev-test-role` in the `test-system` namespace that grants `update` permissions on `namespaces`.
- Create a `RoleBinding` named `dev-test-role-binding` binding that new Role to the SA you found in Step 1.

---

<br>

### Step 1 — Extract the Pod's ServiceAccount Name & Save to File

1. **Approach A — Extract the exact name cleanly via `jsonpath` (Recommended)**

```bash
k get pod nginx-pod -n test-system -o jsonpath='{.spec.serviceAccountName}' > /candidate/KSC00124.txt
```

2. **Verify the file contents**

```bash
cat /candidate/KSC00124.txt; echo
```

- **What this does**
  - Pulls *only* the `serviceAccountName` value (`secret-reader-sa`) from `nginx-pod`'s spec—zero extra noise—and writes it straight to `/candidate/KSC00124.txt`.
- **Example output**
<img width="1125" height="26" alt="image" src="https://github.com/user-attachments/assets/bd743f23-af64-496c-8759-a5a56068fe51" /> 
<img width="527" height="47" alt="image" src="https://github.com/user-attachments/assets/b5caebe2-de9c-4b6a-a8df-f0e4c0bd53eb" />

- **Alternative approach**
  - If you blank on `jsonpath` syntax during the exam, eyeball it via `grep` and manually `echo` the string into the file.

```bash
k get pod nginx-pod -n test-system -o yaml | grep -i serviceAccountName
echo "secret-reader-sa" > /candidate/KSC00124.txt
```

- **Example output**
<img width="856" height="76" alt="image" src="https://github.com/user-attachments/assets/d458d999-10cc-456a-9318-443c7098068c" />

---

<br>

### Step 2 — Create the Role

- Using imperative commands here is way faster than hand-rolling YAML and eliminates typo risk.

```bash
k create role dev-test-role \
  --verb=update \
  --resource=namespaces \
  -n test-system
```

- **`--verb=update`**
  - Defines the allowed action. If you need multiple verbs, separate them with commas (e.g., `--verb=get,list,update`).
- **`--resource=namespaces`**
  - Specifies the target Kubernetes resource type.
- **`-n test-system`**
  - A `Role` is namespace-scoped, so always pass the namespace flag explicitly.
- **Example output**
<img width="497" height="117" alt="image" src="https://github.com/user-attachments/assets/22559081-d627-4a5d-acca-49902f30663e" />

---

<br>

### Step 3 — Create the RoleBinding

Bind the Role from Step 2 (`dev-test-role`) to the ServiceAccount you found in Step 1 (`secret-reader-sa`).

```bash
k create rolebinding dev-test-role-binding \
  --role=dev-test-role \
  --serviceaccount=test-system:secret-reader-sa \
  -n test-system
```

- **`--role=dev-test-role`**
  - The name of the Role you're binding.
- **`--serviceaccount=test-system:secret-reader-sa`**
  - You **must** use the `<Namespace>:<SA-Name>` format with a colon.
- **Example output**
<img width="666" height="122" alt="image" src="https://github.com/user-attachments/assets/ebc7dece-3ef4-4ac2-aceb-d2fac5045d12" />

---

<br>

### Step 4 — Verify RBAC Enforcement (`auth can-i`)

1. **Confirm the `update` permission is active (Expected — `yes`)**

```bash
k auth can-i update namespaces --as=system:serviceaccount:test-system:secret-reader-sa -n test-system
```

- **Example output**
<img width="1127" height="97" alt="image" src="https://github.com/user-attachments/assets/a5943b18-fcba-4fb3-aa99-f5d7564f541d" />

2. **Confirm ungranted permissions like `delete` are blocked (Expected — `no`)**

```bash
k auth can-i delete namespaces --as=system:serviceaccount:test-system:secret-reader-sa -n test-system
```

- **Example output**
<img width="1131" height="90" alt="image" src="https://github.com/user-attachments/assets/06d14127-499f-40cb-9066-f7ea91d832f9" />

- This is the most reliable way to prove your RBAC works as intended before moving on to the next exam question.
- **`--as=system:serviceaccount:<Namespace>:<SA-Name>`**
  - The canonical internal username (Subject) format Kubernetes uses to identify a ServiceAccount.

---

<br>

### ⚠️ What Happens If You Write It Wrong? (Classic Footguns)

- **Dropping the namespace in `--serviceaccount=secret-reader-sa`**
  - Fails immediately with `error: serviceaccount must be <namespace>:<name>`.
  - Even though you already passed `-n test-system` for the RoleBinding itself, you still have to prefix `test-system:` inside the `--serviceaccount` flag.
- **Leaving junk text inside `/candidate/KSC00124.txt`**
  - Redirecting raw `grep` output (e.g., `serviceAccountName: secret-reader-sa`) will fail the automated grader.
  - Always run `cat /candidate/KSC00124.txt` to verify that *only* the pure SA name (`secret-reader-sa`) is in the file.
- **Creating a `ClusterRole` just because `namespaces` is a cluster-scoped resource**
  - In production, yes—`namespaces` is cluster-scoped, so you'd normally reach for a `ClusterRole`.
  - However, when an exam prompt explicitly tells you to create a **`Role` and `RoleBinding`** inside a specific namespace, follow the prompt to the letter or the grading script will mark it wrong.
