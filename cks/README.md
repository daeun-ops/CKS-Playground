# Certified Kubernetes Security Specialist 3Days Crash! 

- **Goal** Drill core hands-on exercises and mock exam patterns over 3 days to pass with 67%+ (Kubernetes v1.34).
- **Strategy** Lock down **Domains 4, 5, and 6 (60% weight)** without mistakes, and quickly nail the standard patterns for **Domains 1, 2, and 3 (40% weight)**.

---

## Day 1 Infrastructure & Access Lockdown (Domains 1, 2, 3 — 40% Total)
> Heavy overlap with CKA, making it easy to build momentum. Focus on YAML indentation and getting commands into muscle memory.

### [Domain 1] Cluster Setup (15%) — `01-cluster-setup-netpol-cis-tls/`
- [ ] Write **NetworkPolicy** from scratch (default deny all + targeted allow rules)
- [ ] Distinguish **AND vs OR** in NetworkPolicy selectors (single `- from:` block = AND, separate blocks = OR)
- [ ] Always allow **DNS (UDP 53)** when restricting Egress (otherwise service discovery breaks completely)
- [ ] Block cloud metadata IP (`169.254.169.254/32`) using `ipBlock.except`
- [ ] Run `kube-bench` and fix master/node findings (`--anonymous-auth=false`, `--profiling=false`, `--insecure-port=0`)
- [ ] Harden kubelet config (`/var/lib/kubelet/config.yaml`) and run `systemctl restart kubelet`
- [ ] Create TLS Secret from cert files and configure **Ingress TLS**
- [ ] Verify `kubectl` binary integrity using `sha256sum --check`
- [ ] **Practice Done** `Q02`, `Q10`, `Q13`, `Q15` (Exercises 01, 02, 03)

### [Domain 2] Cluster Hardening (15%) — `02-cluster-hardening-rbac-sa/`
- [ ] **RBAC** Create `Role` + `RoleBinding` (namespace-scoped) vs `ClusterRole` + `ClusterRoleBinding` (cluster-wide) imperatively
- [ ] Audit existing bindings (`k get clusterrolebinding -o wide | grep cluster-admin`) and delete over-privileged ones
- [ ] Verify permissions with `k auth can-i <verb> <resource> --as=system:serviceaccount:<ns>:<sa>`
- [ ] Verify API server blocks anonymous access (`--anonymous-auth=false`, `--authorization-mode=Node,RBAC`)
- [ ] Disable auto-mounting tokens on **ServiceAccounts** (`automountServiceAccountToken: false`)
- [ ] **Practice Done** `Q01`, `Q07`, `Q12` (Exercises 04, 05)

### [Domain 3] System Hardening (10%) — `03-system-hardening-apparmor-seccomp/`
- [ ] **AppArmor** Check status on nodes (`aa-status`) and load profiles (`apparmor_parser -q`)
- [ ] **Gotcha (v1.34):** Apply AppArmor using the GA field **`securityContext.appArmorProfile`** (`type: Localhost`), NOT the deprecated annotation
- [ ] **Seccomp** Apply `RuntimeDefault` and `Localhost` profiles (stored under `/var/lib/kubelet/seccomp/`)
- [ ] Minimize host OS attack surface (disable unused services via `systemctl disable --now`, patch unnecessary `NodePort` services to `ClusterIP`)
- [ ] **Practice Done** `Q09` (Exercise 06)

---

## Day 2 Pod Security & Supply Chain (Domains 4, 5 — 40% Total)
> Pure CKS territory. Since this accounts for 40% of the score, drill API server restart waits and YAML structures until error-free.

### [Domain 4] Minimize Microservice Vulnerabilities (20%) — `04-microservice-secctx-encrypt-psa/`
- [ ] **Memorize Full SecurityContext Pattern** `runAsNonRoot: true`, `runAsUser: 1000`, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities.drop: ["ALL"]`
- [ ] **Pod Security Admission (PSA)** Apply namespace labels (`enforce`, `audit`, `warn` × `privileged`, `baseline`, `restricted`) — PSP is removed
- [ ] **Encrypt Secrets at Rest** Generate 32-byte key (`head -c 32 /dev/urandom | base64`) and write `EncryptionConfiguration` (`aescbc`)
- [ ] **Gotcha** Put `aescbc` first and `identity: {}` last in `EncryptionConfiguration`, then re-encrypt existing secrets (`k get secrets -A -o json | k replace -f -`)
- [ ] **RuntimeClass** Create gVisor class (`handler: runsc`) and assign via `runtimeClassName` on pods
- [ ] **ValidatingAdmissionPolicy** Enforce policies natively using CEL expressions without external webhooks
- [ ] **Practice Done** `Q03`, `Q06`, `Q11`, `Q16` (Exercises 07, 08, 12)

### [Domain 5] Supply Chain Security (20%) — `05-supply-chain-trivy-image/`
- [ ] **Trivy** Scan images (`trivy image --severity CRITICAL,HIGH <image>`) and swap vulnerable tags for clean Alpine/Distroless variants
- [ ] **Dockerfile Best Practices** Multi-stage builds, non-root `USER`, no `:latest` tags, minimal base images
- [ ] Restrict allowed image registries (`ValidatingAdmissionPolicy` / `ImagePolicyWebhook`)
- [ ] Understand immutable image digests (`@sha256:...`) vs mutable tags (`:1.27`)
- [ ] Run static analysis tools (`kubesec scan`, `conftest test`, `trivy config`) on manifests and Dockerfiles
- [ ] **Practice Done** `Q05` (Exercise 09)

---

## Day 3 Runtime Detection & Full Mock Exam (Domain 6 — 20% + Simulation)
> One typo here breaks the API server or Falco service. Practice the edit → wait → verify log loop until automatic.

### [Domain 6] Monitoring, Logging and Runtime Security (20%) — `06-runtime-audit-falco/`
- [ ] **Audit Logging** Differentiate the 4 levels (`None` < `Metadata` < `Request` < `RequestResponse`)
- [ ] Write `/etc/kubernetes/audit/policy.yaml` and add flags (`--audit-policy-file`, `--audit-log-path`) to `kube-apiserver.yaml`
- [ ] **Gotcha** Mount **BOTH** the policy file directory and the log output directory (`volumeMounts` + `hostPath` `volumes`)
- [ ] **Falco** Check service status (`systemctl status falco`) and inspect alerts (`journalctl -u falco`)
- [ ] Write custom rules in `/etc/falco/rules.d/` (`rule`, `desc`, `condition`, `output`, `priority`) and run `systemctl restart falco`
- [ ] **Runtime Immutability** Export running pods, set `readOnlyRootFilesystem: true`, and mount `emptyDir` volumes for `/tmp`, `/var/cache/nginx`, and `/var/run`
- [ ] **Incident Investigation** Trace malicious processes using `ps aux`, `ss -tlnp`, and `crictl ps` / `crictl inspect` on nodes
- [ ] **Practice Done** `Q04`, `Q08`, `Q14`, `Q17` (Exercises 10, 11)

### Afternoon 17 Question Mock Exam Time Attack (2hr Limit)
- [ ] Run `cheatsheet/01-setup.sh` within the first 60sec for aliases and vim config
- [ ] Complete Q01–Q17 in 2 hours, switching contexts (`k config use-context`) before every task
- [ ] Flag anything taking over 8 minutes and move on (Two-pass approach)

---

## Checklist (Read Before Exam)
1. **Context Switch** Run `k config use-context <cluster-name>` before every single question.
2. **Namespace Check** Set `kn <namespace>` immediately so nothing gets created in `default` by mistake.
3. **Backup Static Pod Manifests** Always backup `/etc/kubernetes/manifests/kube-apiserver.yaml` to `/tmp/` before editing (`cp /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/`) for instant rollback if the API server fails to restart.
4. **Terminal Copy/Paste** Use `Ctrl+Shift+C` and `Ctrl+Shift+V`.
5. **Always Verify** Never move on without checking `k get pod`, `k auth can-i`, or `journalctl -u falco` to confirm the fix actually works.
