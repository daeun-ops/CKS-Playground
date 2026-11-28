# CKS Study Roadmap

Aligned with the official CNCF / Linux Foundation CKS exam objectives (Kubernetes v1.34, as of June 15, 2026).

| Exam Domain | Lab Numbers |
|---|---|
| Cluster Setup | 03, 05, 06, 13, 15, 20, 23, 27 |
| Cluster Hardening | 01, 03, 08, 12, 20, 26 |
| System Hardening | 05, 09, 10, 24 |
| Minimize Microservice Vulnerabilities | 04, 09, 10, 11, 12, 13, 19, 24, 27 |
| Supply Chain Security | 06, 07, 16, 21, 22 |
| Monitoring, Logging and Runtime Security | 02, 14, 17, 18, 25 |

## Additional Focus Areas

The labs cover solid hands-on drills, but don't just memorize the exact steps. Make sure you can also handle these on your own:

- Enforce Pod Security Standards (PSS) instead of legacy PSP setups.
- Configure seccomp and AppArmor using the current syntax for the exam's k8s version.
- Set up workload identity and lock down ServiceAccounts with least privilege.
- Handle SBOMs, image signing/verification, allowed registries, and static analysis.
- Write Kubernetes audit policies and dig through audit logs.
- Write and test custom Falco rules rather than just watching default alerts.
- Set up pod-to-pod encryption using Cilium or Istio.
- Look up info in the allowed docs fast while on the clock.
