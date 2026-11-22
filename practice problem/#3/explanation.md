# NetworkPolicy: Enforcing Default Deny

## Walkthrough & Command Breakdown

### Checklist
- [ ] `k create sa backend-qa -n qa` (don't forget the namespace flag)
- [ ] `k auth can-i get secrets --as=system:serviceaccount:qa:backend-qa -n qa` → verify it returns `no`
- [ ] Update `serviceAccountName: backend-qa` inside the YAML manifest
- [ ] Run `k replace --force -f /home/cert_masters/frontend-pod.yaml` to force-recreate the Pod and verify it reaches `Running`

<br>

### Core Constraints
Out of the box, Kubernetes networking is completely flat and **Allow-All**.  
Your objective here is to lock down the `test` namespace by deploying a **Default Deny** `NetworkPolicy` that drops all incoming (**Ingress**) and outgoing (**Egress**) traffic for every single Pod in that namespace.

---

### Step 1 Switch Cluster Context

```bash
kubectl config use-context dev
```

- Mandatory in the real exam environment. *(Skip this if you're practicing on a single-cluster Killercoda sandbox—it'll just throw an error.)*

---

<br>

### Step 2 Author the NetworkPolicy YAML

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-network
  namespace: test
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

- Open `/home/cert_masters/network-policy.yaml` and drop in the manifest above.
  - **Exam Pro-Tip** Don't hand-type this from scratch during the exam. Pull up the official Kubernetes docs, search for `NetworkPolicy`, and copy-paste the Default Deny template. It's faster and eliminates silly indentation typos.
  - **`podSelector {}`** Leaving the curly braces empty tells Kubernetes to target **every Pod** in the `test` namespace.
  - **`policyTypes`** Declares which traffic directions this policy governs. Listing both `Ingress` and `Egress` without defining any allow rules (`ingress:` or `egress:`) underneath implicitly drops all traffic in both directions.
- **Example output**  
<img width="653" height="267" alt="image" src="https://github.com/user-attachments/assets/9926df34-2ea3-4a2f-af77-ec1dbe64ec5c" />

---

<br>

### Step 3 Apply the Policy & Verify Traffic Blocking

- **Apply the manifest**
  ```bash
  k apply -f /home/cert_masters/network-policy.yaml
  ```
  - **Example output**
<img width="667" height="45" alt="image" src="https://github.com/user-attachments/assets/14ca7a1e-c741-437c-a0cb-c48c1eb7f1ea" />

- **Inspect the policy details to confirm it's configured properly**
  ```bash
  k describe netpol deny-network -n test
  ```
  - **Example output**
<img width="807" height="286" alt="image" src="https://github.com/user-attachments/assets/3d9dd29d-d130-4859-b3db-602c752e5525" />

<br>

#### Live Blocking Test

- **Grab the `web` Pod's IP address:**
  ```bash
  WEB_IP=$(k get pod web -n test -o jsonpath='{.status.podIP}')
  ```
- **Attempt to hit the `web` Pod from the `client` Pod (with a 3-second timeout)**
  ```bash
  k exec -n test client -- wget -T 3 -qO- http://$WEB_IP
  ```
- **Example output** *(If you see `wget: download timed out`, the policy is working and traffic is completely choked off.)*
<img width="767" height="92" alt="image" src="https://github.com/user-attachments/assets/c29514b7-da5c-4222-bf72-3c04d90511f9" />

---

<br>

### ⚠️ What Happens If You Write It Wrong? (Classic Footguns)

- **Accidentally adding `ingress: [{}]` or `egress: [{}]`**
  - An empty object inside an array (`[{}]`) does **not** mean "deny"—it means **"Allow All traffic."**
  - For a true Default Deny, either omit the `ingress:` / `egress:` fields completely or explicitly pass an empty array (`[]`).
- **Only listing `Ingress` under `policyTypes`**
  - You'll block inbound traffic, sure, but outbound (`Egress`) traffic from your Pods to other Pods or the outside internet stays wide open.
- **Deleting the `podSelector` field altogether**
  - `podSelector` is a **required** field in the spec. Leaving it out will cause `kubectl apply` to blow up with a schema validation error.
