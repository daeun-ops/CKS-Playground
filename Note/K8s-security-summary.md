# PART 1 The Layers of Security Boundaries

Breaking down what we need to protect and where to draw the line across different layers.

## The 4C Model of Cloud-Native Security

 💡 **Container Security:** If the outer layer gets breached, the inside is compromised. 

- This model only works when you implement defense-in-depth across all four layers. </aside>

<img width="297" height="267" alt="image" src="https://github.com/user-attachments/assets/d8bdb031-5e5a-4e4d-b154-c6fe6be9dc51" />

**Cloud**: The underlying infrastructure where the cluster is deployed.

**Cluster**: Includes the various components of the container orchestrator that manage and operate containers.

**Container**: The runtime environment containing your code, along with the libraries needed to run the application deployed in the cluster.

**Code**: The actual application code living inside the container.


1️⃣ **The Premise of Trust**

Inner layer security is completely built on the assumption that the outer layer is already secured.


2️⃣ **Order of Hardening**

**Cloud → Cluster → Container → Code.** You have to lock down the perimeter from the outside in to make your defense solid.


3️⃣ **Separation of Duties**

Each layer requires different control mechanisms and different owners. The entire organization needs to look at this holistically.


---

## NIST SP 800-190 — Container Technology Threat Landscape

💡 **Container Security**: The four pillars of risk: Image, Registry, Orchestrator, and Container.

- Based on the US NIST standard guidelines.


### Image

- Contains known vulnerabilities.
- Hardcoded secrets and credentials.
- Using untrusted base images.

### Registry

- Unencrypted communication with the registry.
- Storing vulnerable images.
- Weak authentication and authorization.

### Orchestrator

- Over-provisioning permissions to cluster users (God-mode).
- Mixing traffic of workloads with different sensitivity levels.
- Vulnerabilities in the nodes making up the cluster.

### Container

- Service disruption due to runtime vulnerabilities.
- Granting excessive privileges to containers.
- Deploying containers that bypassed security scanning.

<img width="417" height="239" alt="image" src="https://github.com/user-attachments/assets/05b0421c-a338-4bc7-8442-3a1e7bfc610f" />

<img width="2816" height="1536" alt="image" src="https://github.com/user-attachments/assets/6f40aae7-36f2-4eb8-851f-0c77c12057dd" />

    
NIST Special Publication (SP) 800-190, Application Container Security Guide

---

## Security Boundaries: Network, Isolation, and the API Layer


🔑 Leaving one layer open exposes the other two. You have to look at all three layers together to actually shut down the attack vectors.


<img width="322" height="311" alt="image" src="https://github.com/user-attachments/assets/4af99f2d-bf2b-4029-8270-850141d5b77d" />

## Auditing the vanilla defaults of these three layers is our starting point here.

### Network Layer

- **Controls pod-to-pod traffic and outbound cluster traffic.**
  - *(Default: Allow-All)*

### Isolation Layer

- **Segments workloads using Namespaces and Nodes, and restricts container execution privileges.**
  - *(Default: Privileged execution is NOT blocked)*

### API Layer

- **Controls who can do what. Every state change goes through here, making it the ultimate control plane.**
  - *(Default: Service Account tokens are auto-mounted)*

---

## Shifting Network Controls from Default-Allow to Default-Deny

🔑 Out of the box, Kubernetes is a flat network—every pod can talk to every pod. Isolation only happens when you declare it, so keeping the defaults means lateral movement is wide open.


### Is there a Network Policy targeting this Pod?

**Case 1. None at all.** 

- **Any pod can reach this pod.**
  - *(This is the vanilla default)*

**Case 2. At least one policy exists.** 

- **Only the traffic explicitly allowed by that policy can pass.**
  - *(Everything else is implicitly denied)*

**How to define it** 

- You select target pods using Label selectors and define ingress (incoming) and egress (outgoing) rules separately.
  - *Egress is usually what people forget to lock down.*

⚠️ **Your Plugin Must Support It** 

**If you write a Policy but your Network Plugin (CNI) doesn't support it, K8s will silently ignore it without throwing errors.**

*You'll think you're locked down, but you're actually wide open.*


**How to verify enforcement** 

- Actually try to hit the endpoint from a pod that should be blocked. *“The Policy YAML is applied” is not proof that the traffic is blocked.*
- The safest approach is laying down a default-deny policy per Namespace first, then poking holes only for the traffic you actually need.

---

## The Isolation Layer: Segmenting Workloads via Nodes and Namespaces

🔑 Logical isolation and physical isolation have completely different strengths. If you don't define your compliance requirements, you have no baseline to judge whether Namespaces are "enough."


### Desired Level of Isolation

**(Gets stronger and more expensive as you go down)**

### Namespace

**What it isolates** 

- Naming scope and RBAC
- Resource quotas

**What it shares** 

- Node / Kernel / Control Plane

Lowest cost overhead.


### Node Isolation

**What it isolates** 

- Naming scope, RBAC, and quotas
- Kernel and Hardware

**What it shares** 

- Control Plane

Increases idle resource overhead.


### Cluster Isolation

**What it isolates** 

- Everything above
- Control Plane

**What it shares** 

- Nothing

Highest operational overhead.


🚷 **Rule of Thumb for Selection** 

**Write down your isolation requirements in a sentence first, then pick the cheapest isolation method that satisfies it.** 

*— Evaluate from top to bottom (Namespace -> Node -> Cluster).* 


---

## When Namespaces Just Aren't Enough

🔑 **The fact remains: you are still sharing the Node and the Kernel.** 

*— If compliance rules or strict trust boundaries are in play, logical isolation won't cut it.*


| **Isolation Target** | **Namespace Isolation** | **Node Isolation** | **Cluster Isolation** |
| --- | --- | --- | --- |
| **Naming & RBAC** | **Isolated** | **Isolated** | **Isolated** |
| **Resource Quotas** | **Isolated** | **Isolated** | **Isolated** |
| **Node & Kernel** | **Shared** | **Isolated** | **Isolated** |
| **Control Plane Outages** | **Shared Blast Radius** | **Shared Blast Radius** | **Isolated** |


### When Namespaces are enough
- Segmenting teams or environments within the same organization.
- Preventing resource contention and naming collisions.
  - *Most internal enterprise needs fall into this bucket.*

### When you need to spin up separate Clusters
- When external orgs with different trust boundaries share the same cluster.
- When regulatory compliance mandates hard physical infrastructure separation.
  - *In these cases, you eat the operational cost and split the clusters.*

---


## Namespace Design: Coupling Services with Environments

🔑 **If you segment purely by environment, you still get cross-service interference.**

 *— You need to combine the Service name with the Environment so that the downstream Policies are bounded at the Service level.* 


### Segmented purely by Environment (The Anti-Pattern)

- No structural place to apply policies and RBAC on a per-service basis.

| **DEV** | **QA** | **PROD** |
| --- | --- | --- |
| Service-A | Service-A | Service-A |
| Service-B | Service-B | Service-B |
| *Lumped together* | *Lumped together* | *Lumped together* |

### Segmented by Service + Environment (The Best Practice)

- Boundaries are drawn per Service, so policies and RBAC align perfectly with the architecture.

| **A-Dev (Service A)** | **A-Qa (Service A)** | **A-Prod (Service A)** |
| --- | --- | --- |
| **B-Dev (Service B)** | **B-Qa (Service B)** | **B-Prod (Service B)** |

### What you can enforce at the Namespace level

1. **Total Resources** 
  - Setting hard ceilings for CPU and Memory per boundary.
2. **Network Policies**
  - Defining which boundaries can talk to which.
3. **RBAC Scope** 
  - Granting Roles that are only valid inside this specific boundary.

⚠️ **What you CANNOT block with boundaries** 

Cluster-wide outages don't respect Namespace boundaries — 

If you want to shrink that blast radius, you have to split the cluster, which scales up your management overhead.


---

# PART 2 Access Control (Who can do what)

Looking at how we delegate permissions and audit their usage.

## Delegating RBAC so Cluster Admins can step back


🔑 **Vanilla admin roles have God-mode.** 

*— You need to create scoped-down Roles and hand off Namespace admin privileges to product teams so they actually own their actions.*


### How permissions are bound

```python
**Role -------**→ **RoleBinding** --------→ **User 

*Roles are scoped to a single Namespace. If you need cluster-wide permissions, you need a ClusterRole.***
```

### **Role**

*What can they do?* 

- Create a **Deployment**
- Read a **Secret**
- Delete a **P**ersistent**V**olume**C**laim

### **RoleBinding**

*Who gets it?*

### User

*Or a **S**ervice **A**ccount*

### The direction of delegation

```python
**Cluster (Team-Admin)** --------------(**Delegates**)----------------> **Team-Product 

*The Cluster Team-Admin focuses solely on cluster ops and hands off product-level decisions.***
```

### Cluster (Team-Admin)

*Instead of using cluster-admin (God-mode), they use a custom scoped-down Role.* 

- **Permissions to manage Nodes and shared infrastructure.**
- **Read-only access to Service boundaries (excluding Secrets).**

### Team-Product

*They make decisions and execute autonomously inside their own Namespace.*

- **Given a default admin Role for their namespace.**
- **They can carve it up further internally if needed.**

### Principles of Auth Design

**Having permissions means owning the responsibility.** 

- The org's definition of responsibility and the system's RBAC must be in sync.
- If you only do one, your paper policies won't match reality.
  - *Handing out cluster-admin to everyone is just giving up on security.*

### Things to coordinate (Current State)

**Pod Security Admission (PSA) has taken over since PodSecurityPolicy (PSP) was deprecated.** 

- RBAC controls *who can mutate resources*.
- What permissions the Pod *actually runs with* is controlled by a separate mechanism (PSA/PSS).
  - *If you confuse the two, you might lock down user RBAC but leave container execution privileges wide open.*

---

## The Auto-Mounted Service Account Token


🔑 **Tokens are injected even if you don't ask for them.** 

*— If you don't opt out on pods that don't need it, it becomes an API pivot point during a breach.*


| **SA is auto-created** |  **Token is injected into Pod** | **Turn it off if you don't need it** | **Create a dedicated SA if you do** |
| --- | --- | --- | --- |
| **Creating a Namespace auto-generates a 'default' Service Account.** | **Even if you don't specify an SA, the default SA's token is mounted as a file inside the Pod.** | **Disable auto-mounting for workloads that don't talk to the K8s API.** | **For workloads that need the API, create a dedicated SA with least-privilege RBAC.** |
|  |  |  |  |
| *It's there whether we make it or not.* | *Whoever compromises that pod can hit the API server.* | *99% of your applications fall into this category.* | *If you attach permissions to the default SA, every pod inherits them.* |

### How to verify

- **Exec into the Pod, check if the token file exists, and run tests to see what you can query with it.**
  - Double-check that the default Service Account actually has zero permissions. 
    *— I've seen plenty of clusters where someone attached God-mode to 'default' just for convenience.*

---

## Certificates and Authentication: The Silent Cluster Killer

🔑 **Kubeadm cluster certs default to 1 year.** 

*— If you don't upgrade, they don't renew. If you don't monitor expiration dates, one day your API Server will just hard stop.*


### Certificates used by the Cluster

- **Used for mutual TLS between API Server, Kubelet, and ETCD.**
- <u>**Kubeadm issues them with a 1-year lifespan by default.**</u>
- **They get rotated automatically during cluster upgrades.**

**When they expire, the cluster dies.** 

- *A cluster left untouched for over a year is a ticking time bomb.*

### **How humans authenticate**

- **The default <u>kubeconfig</u> uses client certificates.**
- **There is no Certificate Revocation List (CRL) in K8s, making revocation a nightmare.**
  - *For humans, hooking OIDC to your corporate IdP is much safer.*

**Can you revoke access when someone leaves?** 

- *If you handed out raw certs, practically, no.*

### How Workloads authenticate

- **Short-lived tokens auto-injected into Pods.**
- **Bound to an audience (Target) and expiration, so they can't be replayed elsewhere.**
- **Very different from the old non-expiring Secret Tokens.**

**Keep human credentials out of Pods.** 

- <u>*Workloads should only authenticate via Service Accounts.*</u>

### Day 2 Ops Checklist

```python
**Put cert expiration dates into your alerting stack.** 

**Tie human access to corporate IdP via OIDC.** 

**Stop sharing kubeconfig files.**
```

---

## Audit Logs: The "Who Did What" Ledger

🔑 **Since every state change routes through the API, everything gets logged here.** 

*— If you don't enable this, you have zero forensics to work with post-breach.*


### The path of an audit log

<img width="581" height="330" alt="image" src="https://github.com/user-attachments/assets/5793f200-ffd5-41b1-9501-5cfa7690bd08" />


---

⚠️ **If you store logs locally inside the cluster, they get wiped by the attacker during a breach.**


### Choosing your log verbosity

- **Log everything, and you'll drown in storage costs. Log too little, and it's useless for forensics.**
- **Tune verbosity based on the Resource type.**
  - *Access to secrets needs to be highly detailed.*

### Defining retention policies

- Base it on the longer of two metrics: compliance requirements vs. practical forensic needs.
  - *Make sure to lock down access to the logs themselves.*

### Questions your logs must answer

- **Who changed this config, and when? / Which account read this secret? / Where did this failed auth attempt originate?**
- **If your logs can't answer these three, revisit your verbosity and retention.**
  - *You can't retroactively generate logs after an incident happens.*

---

## Audit Policies: Tuning Verbosity per Resource

🔑**Logging everything kills your disks; logging nothing kills your incident response.**

*— Setting different logging levels per Resource is the industry standard.*


### The 4 levels of logging per request

```python
**None (Don't log at all) --->
Metadata (Who did what to what) --->
Request (Includes the payload sent) --->
RequestResponse (Includes the payload and the server's response)**
```

**Apply differently per Resource** 

- Secrets should be `Metadata` so you don't leak values; RBAC modifications should be `RequestResponse`.
- If you blanket-apply one level, it'll be wrong for half your cluster.

**Weigh the Volume**

- Logging `get`/`list` requests will cause an explosion in log volume.
- Filter out most read-only ops and focus heavily on state-mutating ops (writes).

**Ship them out of the cluster** 

- If they only live on the Node disk, they die when the Node dies.
- Ship them to external storage with strict retention rules if you want them useful for forensics.

---

# PART 3 Execution Constraints (Locking down the Container)

Shrinking the attack surface by reducing what the container is legally allowed to do.

## Blocking Container Privilege Escalation

🔑 **Because containers share the kernel, one escape compromises the entire node.**

*— Logical boundaries are useless if they don't align with actual trust boundaries.* 


### **The attack path when left open**

```python
**A single container is compromised.** 
----> 
**It's running as root, granting access to kernel capabilities.** 
----> 
**Attacker owns the entire Node and every other container running on it.**
```

### **How to enforce it**

- **Don't just trust workloads to behave. Use Admission Controllers to reject non-compliant workloads before they spin up.**
  - *This is where the Admission Control we talked about in PART 2 shines.*

### Rollout Strategy

- Start in 'Warn' mode. See what triggers the alerts, fix the workloads, and *then* flip the switch to 'Enforce'.

> **Run as Non-Root** 
*- Force the image to create a standard user and run as that user.*
> 

> **Block Privileged Mode & Host Access**
*- Reject privileged containers and host namespace sharing at the Admission gate.*
> 

> **Read-Only Root Filesystems**
*- Mount separate Volumes strictly for paths that actually require write access.*
> 

> **Drop Kernel Capabilities**
*- Drop ALL default kernel capabilities (`Drop: ALL`), then explicitly add back only the ones you desperately need.*
> 

---

## Pod Security Profiles (Applied with a single Namespace Label)

🔑 **3 Profiles (Privileged / Baseline / Restricted) matched with 3 Modes (Enforce / Audit / Warn).**

*— It's much safer to start with `warn` to see what breaks before pushing it to `enforce`.* 


### Privileged (Wide open)

- **Zero restrictions applied.**
- **Should strictly be reserved for Namespaces running System Components.**
- **Never use this for standard workload Namespaces.**

**The out-of-the-box default**

- *Namespaces without labels default to this behavior.*

### **Baseline (Blocks known privilege escalations)**

- **Blocks privileged containers and host namespaces.**
- **Most existing workloads will pass this without requiring refactoring.**
- **The best place to start your hardening journey.**

**A realistic Day-1 goal**

- *You can usually bump up to this without breaking production.*

### Restricted (Modern Best Practice)

- **Mandates `runAsNonRoot`.**
- **Requires dropping capabilities and disallowing privilege escalation.**
- **Requires you to refactor your Images and Manifests to pass.**

**Requires actual engineering effort**

- *It's significantly easier to enforce this on greenfield (new) workloads first.*

### Layering the 3 Modes for a phased rollout

```python
**Warn -- Allows deployment, throws a warning to the user.**

**Audit -- Allows deployment, logs the violation to the audit backend.**

**Enforce -- Hard blocks the Pod creation.**
```

---

## How Attackers chain defaults to bypass security

🔑 **If they hit one layer, they get blocked. If they chain the gaps together, they own your cluster.**

*— Siloed checks won't save you; you have to evaluate the entire attack chain.*


**Breaking any single link in this 4-step chain stops the attack — which is why we map attack paths instead of just auditing layers.**

> 
> 
> 1. **A single Pod is compromised.
> - An application vulnerability gives the attacker remote code execution (RCE) inside the container.**
> - *This happens on any system, K8s or not.*

> 
> 
> 2. **They hit the API with the injected Token.
> - Auto-mount wasn't disabled, so the token is sitting right there in the filesystem.**
> - *The Fix: Disable auto-mount (`automountServiceAccountToken: false`).*

> 
> 
> 3. **They leverage overly broad RBAC for recon.
> - Permissions were too loose, allowing them to read Secrets from other Namespaces.**
> - *The Fix: Enforce Least Privilege RBAC.*

> 
> 
> 4. **Lateral movement and Node takeover.
> - No Network Policies means they can pivot freely to internal services. They spin up a privileged container and own the Node.**
> - *The Fix: Default-deny NetworkPolicies and blocking privileged execution via PSS.*

---

## Secrets at Rest: Plain text if you don't turn on Encryption

🔑 **Kubernetes Secret Objects are merely base64 encoded, not encrypted.** 
*— Anyone with access to the ETCD files or a snapshot can read your secrets in plain text.*


### Secret Data - Protective Measures

⚠️ **The Default State
Stored as base64 encoded strings.** 
*— You literally don't even need a key to decode it.*

🔒

**Encryption at Rest
Must be explicitly enabled via API Server config.**
*— Note: Pre-existing secrets must be rewritten to trigger encryption.*


🗄️

**Securing Snapshot Files
An ETCD backup is basically a giant zip file of your secrets.**
*— You need to strictly control both the storage location and IAM access to those backups.*


🔑

**External Secrets Management
Move secrets entirely out of the cluster (Vault, AWS SM, etc.).**
*— Gives you native rotation and centralized auditing.*


### The Most Common Misconception

- **People assume creating a `Secret` object makes it secure, but you have to actively enable encryption.**
  - *Don't let the name fool you.*

### What else to look out for

- **Audit exactly who (and what) has RBAC permissions to `get`/`read` Secrets.**
- **Over-privileged RBAC is a much more common leak vector than someone stealing your ETCD drive.**

---

# PART 4 Supply Chain and Runtime Security

Verifying what enters your cluster, and watching it while it runs.

## The Pre-Deployment Gate: Validating Image Provenance

🔑 **Filtering what enters the cluster right at the gate.** 
*— If you catch it post-deployment, it's already running. We need to shift this control point to the left.*


### The journey of an Image into the Cluster

```
**Build** (Bake the image and sign it)

**--->** 

**Registry Scan** (Catch vulns early)

**--->** 

**Admission Controller** 
(Validates against policy. 
If it fails here, it gets rejected before it ever spins up.)

**--->** 

**Deploy** (Only verified images get to run)
```

### Restricting Provenance (Source)

> 
> 
> - **Only allow images pulled from approved internal Registries.**
> - **Verify cryptographic signatures to ensure no tampering happened in transit.**
>     - *Kills the habit of developers pulling random images directly from public registries.*

### Hooking it into the Pipeline

> 
> 
> - **Make vulnerability scan results a hard gate in your CI/CD pipeline.**
> - **If it hits a critical CVE threshold, the build fails and deployment stops.**
>     - *Scanning without enforcing is just generating noise.*

### Define your baselines first

> 
> 
> - **Zero-vulnerability images practically don't exist.**
> - **If you don't define exactly which severity levels trigger a block, your policies will be ignored.**
>     - *Have a clear, documented process for exception handling.*

---

## Supply Chain Security: Visibility via SBOMs and Locking with Signatures

🔑 **Vulnerability scanners only catch what's known *today*.** 
*— You need an SBOM to map your dependencies and lock the source with signatures. This lets you immediately trace the blast radius when a zero-day drops.*


### The evidence chain an Image needs before it runs

```
**Build** (What is it made of?)

**--->** 

**SBOM Generation** (What's inside it?)

**--->** 

**Signing** (Who built it?)

**--->** 

**Pre-deployment Verification** (Checking signatures and policies)
```

### Why scanning isn't enough

> 
> 
> - Vulnerability scans only catch what is known *at the time of the scan*.
> - An image that passes today can easily become vulnerable *tomorrow*.

### The question an SBOM answers

> 
> 
> - When a new CVE drops, where exactly are the images running that use this compromised library? You can trace it immediately.

### The question a Signature answers

> 
> 
> - Did this image in the registry actually come from our CI pipeline? (Verified at the Admission gate).

---

## Node OS and Runtime Vulnerabilities

🔑 **You can lock down the cluster all you want, but the underlying layers are still exposed.** 
*— If you don't define a patching cycle upfront, you'll always be reacting to fires.*


### The layers we locked down vs. the ones beneath

> **Workload Config
> Cluster Config (RBAC / Policies / Admission)**

> **Container Runtime (Requires separate handling)
> Node OS and Kernel (Requires separate handling)**


| **Target** | **Mitigation Strategy** |
| --- | --- |
| **Node OS** | Use minimal, container-optimized operating systems. |
| **Runtime Vulns** | Rotate Node images based on security advisories. |
| **Rotation Process** | Have a zero-downtime rotation playbook ready. |
| **Runtime Monitoring** | Deploy runtime threat detection tools. |

### Define the cadence upfront

**Advisory Check Cadence** 
- Assign an owner and a frequency for checking Runtime/OS security advisories.

**Target Remediation SLAs**
- Document SLAs for patching based on vulnerability severity (e.g., how many days to rotate).

**Node Rotation Drills**
- Set up PodDisruptionBudgets (PDBs) and regularly practice draining and rotating nodes.

---

## Runtime Security: Catching Anomalous Container Behavior

🔑 **Pre-deployment scans only check what's baked into the image.** 
*— You need an extra layer because unexpected behaviors from a "clean" image only reveal themselves at runtime.*


### Detect (Seeing what happened)

- **Observe system calls made by the container at the kernel level.**
  - *Shell execution inside a container / Accessing sensitive files / Unexpected outbound connections.*
- **Falco is the CNCF-graduated project heavily used for this.**

**What Image scans miss** 
- *The runtime actions of a perfectly benign-looking image.*

### Prevent (Blocking it at the source)

- **Restrict the allowed system calls using Seccomp profiles.**
  - *Use AppArmor/SELinux to lock down file access and capabilities.*
- **The `RuntimeDefault` profile is your lowest barrier to entry.**

**Where to start**
- *Most workloads run perfectly fine out-of-the-box with `RuntimeDefault`.*

### Operations (Tuning the rules)

- **If you just turn on the default rules, you will drown in alert fatigue.**
- **Profile your workloads and whitelist their normal, baseline behavior.**
- **Define exactly who gets paged and what the runbook is for these alerts.**

**The most common failure mode**
- *Turning it on to check a compliance box, but nobody actually monitors the alerts.*

### Each layer answers a different question — One cannot replace the other

```python
**Pre-deployment -- What is inside this?**

**Admission -- Is this allowed to run?**

**Runtime -- What is it actually doing right now?**
```
