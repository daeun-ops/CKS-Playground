# Sandboxing Workloads with RuntimeClass (gVisor)

## Walkthrough & Command Breakdown

### Checklist
- [ ] Verify `apiVersion: node.k8s.io/v1` and `handler: runsc` when creating the `RuntimeClass` (cluster-scoped—no namespace)
- [ ] Verify `spec.runtimeClassName: gvisor-rc` is placed at the Pod spec level (not inside `containers[]`)
- [ ] Validate both `k get runtimeclass` and that the Pod has `runtimeClassName` properly applied

<br>

### Core Constraints
- Standard containers share the host OS kernel, meaning a successful container escape puts the entire host node at risk.
- The goal here is to drop a sandboxed runtime like **gVisor (`runsc`)** between the container and the host kernel to establish a real isolation boundary.
  - Create a `RuntimeClass` named `gvisor-rc` in the cluster backed by the `runsc` handler.
  - Deploy an `nginx` Pod in the `server` namespace configured to run under the `gvisor-rc` `RuntimeClass`.

---

<br>

### Step 1 — Create the RuntimeClass

- There's no imperative `kubectl create` shortcut for `RuntimeClass`, so you'll need to apply it via YAML.

```bash
cat <<EOF | k apply -f -
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor-rc
handler: runsc
EOF
```

- **Exam Pro-Tip** — In the real exam, search **RuntimeClass** in the official Kubernetes Docs and copy-paste the snippet directly. It's the fastest way to avoid typos.
- **`apiVersion: node.k8s.io/v1`** — The current standard Kubernetes API version.
- **`handler: runsc`** — The gVisor execution handler name pre-registered in the node's container runtime (e.g., `containerd`).
- **`RuntimeClass` is cluster-scoped**, so do **not** put a `namespace` field under `metadata`.
- **Example output**
<img width="431" height="178" alt="image" src="https://github.com/user-attachments/assets/fab8c34d-3033-40ab-91f8-6666678da0df" />

---

<br>

### Step 2 — Deploy the Nginx Pod Using the gVisor RuntimeClass

```bash
cat <<EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-gvisor
  namespace: server
spec:
  runtimeClassName: gvisor-rc
  containers:
  - name: nginx
    image: nginx
EOF
```

- You can either generate the Pod skeleton first with `--dry-run=client -o yaml` and add `runtimeClassName`, or just pipe the manifest straight into `k apply`.
- **`spec.runtimeClassName: gvisor-rc`**
  - This is the key field that tells Kubernetes to launch the Pod using **`gvisor-rc`** instead of the default runtime (`runc`).
- **Example output**
<img width="437" height="287" alt="image" src="https://github.com/user-attachments/assets/66ee3c54-ced1-47ee-a4bb-79de99f27f1a" />

---

<br>

### Step 3 — Verify Enforcement

1. **Confirm the `RuntimeClass` exists**

```bash
k get runtimeclass
```

- **Example output**
<img width="376" height="71" alt="image" src="https://github.com/user-attachments/assets/311087f4-ae1f-45c1-9764-c00fe5ebda1a" />

2. **Confirm `runtimeClassName` is applied to the Pod**

```bash
k get pod nginx-gvisor -n server -o jsonpath='{.spec.runtimeClassName}'; echo
```

- **Example output**
<img width="910" height="50" alt="image" src="https://github.com/user-attachments/assets/b71be868-9043-4a1b-a561-112258bda299" />

- **Lab Note**
  - On the actual exam nodes, `runsc` is pre-installed, so the Pod will come right up in a `Running` state.

---

<br>

### ⚠️ What Happens If You Write It Wrong? (Classic Footguns)

- **Putting `runtimeClassName` under `containers[]`**
  - `runtimeClassName` is a **Pod-level** field (`spec.runtimeClassName`), not a container-level field. Nesting it under `containers` will throw an `unknown field` schema error.
- **Using `apiVersion: node.k8s.io/v1beta1`**
  - Relying on outdated docs or old dumps with `v1beta1` will fail on modern Kubernetes clusters since that API version has been removed.
  - Always use **`node.k8s.io/v1`**.
- **Trying to patch `runtimeClassName` onto an already-running Pod**
  - `runtimeClassName` is an **immutable** field, so `k edit` won't let you change it on an existing Pod.
  - You must delete and recreate the Pod (`k replace --force -f`).
