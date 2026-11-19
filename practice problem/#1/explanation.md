# Runtime Security Incident Response: Neutralizing a `/dev/mem` Threat

This scenario tests your hands-on runtime security skills: hunting down a rogue Pod attempting unauthorized access to a critical system memory file (`/dev/mem`) and safely neutralizing it by **scaling its controller down to 0**—without destroying the forensic trail.

---

## Walkthrough & Command Breakdown

### Pre Flight Checklist
- [ ] Verify SSH access to the target Node (`ssh cks...`)
- [ ] Pull the target Pod name from system logs (`syslog` / Falco)
- [ ] Inspect Pod labels via `kubectl get pod <Pod Name> --show-labels`
- [ ] Locate the managing Deployment via `kubectl get deploy -l <Label-Key=Value>`
- [ ] Neutralize the workload with `kubectl scale deployment <Deployment Name> --replicas=0`
- [ ] **(Post-op)** Run `exit` to drop back to the original control-plane/base node *(Critical!)*

### Hard Constraints
- **DO NOT** delete the Pod directly (`kubectl delete pod`). The Deployment's ReplicaSet will just spin up a replacement immediately.
- **DO NOT** delete the Deployment resource itself (`kubectl delete deployment`). We need the manifest intact for Root Cause Analysis (RCA).
- **ONLY** scale the Deployment down to **`replicas=0`**.

<br>

---

### Step 1 SSH into the Target Host (Node)

```bash
ssh cks000026
```

- **What this does:** Connects you directly to the `cks000026` node where the rogue Pod is running and where the local runtime/Falco logs live.
- **Exam Pro-Tip:** Double-check the exact node name specified in the prompt. In the CKS exam, you're constantly jumping between clusters and nodes—running the right commands on the wrong host is an instant zero.

<br>

---

### Step 2 Identify the Rogue Pod Accessing `/dev/mem`

<img width="740" height="77" alt="image" src="https://github.com/user-attachments/assets/c22fd5d8-9f40-4460-a2df-fc73ede46e9e" />

To catch the culprit red-handed, you'll need to parse the Falco alerts or inspect the container runtime directly (`crictl` / `docker`).

#### Approach A Parse Falco Logs (Recommended & Fastest)

```bash
grep falco /var/log/syslog | grep "/dev/mem"
```

- **What this does:** Filters `/var/log/syslog` for Falco alerts specifically triggered by `/dev/mem` access.
- **Alternative paths:** If Falco isn't configured to ship to `syslog`, check `/var/log/falco.log` directly or query systemd via:
  ```bash
  journalctl -u falco | grep "/dev/mem"
  ```
- **What to look for:** The log entry will spit out the exact Pod name—something like `k8s.pod.name=ollama-7b5...`. Copy that name down.

#### Approach B Check via Container Runtime (If the prompt hints at Docker/Runtime)

```bash
docker ps | grep ollama
```

- **What this does:** Lists running containers on the node and filters for anything matching `ollama`.
- **Heads-up:** Modern Kubernetes ditched `dockershim` in favor of `containerd` as the default CRI. On current CKS exams, you'll almost certainly need `crictl` instead of `docker`:
  ```bash
  crictl ps | grep ollama
  ```

<br>

---

### Step 3 Trace the Managing Deployment

Once you have the Pod name (see below), you need to trace it up the ownership chain to find its parent Deployment.

<img width="1005" height="467" alt="image" src="https://github.com/user-attachments/assets/a86f9542-3f94-48dc-8b93-5235f8a8ba71" />

#### Approach A Trace via Labels (Fastest & Most Intuitive)

1. **Inspect the Pod's labels:**
   ```bash
   kubectl get pod ollama-7b5689 -o wide --show-labels
   ```
   *Example output:* `labels -> app=ollama, pod-template-hash=7b5698`

2. **Find the Deployment matching that label:**
   ```bash
   kubectl get deployment -l app=ollama
   ```
   *Example output:*
<img width="1330" height="181" alt="image" src="https://github.com/user-attachments/assets/994ea83d-60e0-45ca-b947-6603352952d5" />

#### Approach B Trace via `ownerReferences` (Exact, but more typing)

```bash
kubectl get pod ollama-7b5689 -o jsonpath='{.metadata.ownerReferences[0].name}'
```

- **What this does:** Uses JSONPath to pull the exact name of the parent controller from the Pod's metadata.
- **Gotcha to watch out for:** This outputs the **ReplicaSet** name (e.g., `ollama-7b5689`), *not* the Deployment name—because a ReplicaSet is the Pod's direct owner. Take the prefix (`ollama`) and match it against `kubectl get deployment`.

<br>

---

### Step 4 Scale the Deployment Down to 0 (Final Remediation)

Once you've confirmed the parent Deployment name (e.g., `ollama`), kill the active replicas by scaling it to zero.

```bash
kubectl scale deployment ollama --replicas=0
```

- **What this does:** Forces the `ollama` Deployment's desired replica count to `0`.
- **Why scale to 0 instead of deleting?**
  If you run `kubectl delete pod ollama-7b5689`, the ReplicaSet's reconciliation loop immediately notices the drift from the desired state (e.g., `replicas: 1`) and spawns a brand-new malicious Pod.
  Scaling to `0` halts execution immediately while preserving the Deployment object in etcd for post-incident RCA.

#### Verification

```bash
kubectl get pods | grep ollama
```

- **Success criteria:** Watch the Pod transition to `Terminating` and then disappear completely from the output. Once it's gone, you're clean—just don't forget to `exit` back to your base node.

- **Example output**
<img width="1330" height="181" alt="image" src="https://github.com/user-attachments/assets/715611a8-7868-45e0-8cb9-88285c57201b" />
