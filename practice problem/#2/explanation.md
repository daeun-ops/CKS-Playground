# Supply Chain Security Image Vulnerability Scanning with Trivy

This scenario evaluates your container supply chain security skills
- identifying container images running in the `nato` namespace, scanning them with **Trivy**, and hunting down and deleting any Pods running images with **HIGH** or **CRITICAL** vulnerabilities.

---

## Walkthrough & Command Breakdown

### Pre Flight Checklist
- [ ] Switch to the right Cluster Context (`kubectl config use-context scanner`)
- [ ] List all Pods and their images in the `nato` namespace (`kubectl get pods -n nato -o custom-columns=...`)
- [ ] Copy the extracted image list into a scratchpad/notepad
- [ ] Run a Trivy scan against each image (`trivy image --severity HIGH,CRITICAL <Image Name>`)
- [ ] Identify which Pods are running images flagged with `HIGH` or `CRITICAL` CVEs
- [ ] Delete the vulnerable Pods (`kubectl delete pod <Pod Name> -n nato`)

### Hard Constraints
- You **must** switch to the correct Cluster Context (`scanner`).
- Run the Trivy scans **only on the Master Node** (Trivy is already pre-installed there).
- Filter strictly for **`HIGH` or `CRITICAL`** vulnerabilities (ignore `LOW` and `MEDIUM`).

<br>

---

### Step 1 Identify Pods and Images in the `nato` Namespace

```bash
kubectl get pods -n nato -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[*].image
```

- **What this does** Queries all Pods in the `nato` namespace and formats the output using `custom-columns` so you can see at a glance which Pod is running which image.
  - Column 1 (`NAME`): The Pod name.
  - Column 2 (`IMAGE`): Every container image defined inside that Pod.
- **Alternative approaches**
  - You *could* use `jsonpath`, but it's unnecessarily verbose—`custom-columns` is much faster and cleaner under exam pressure.
  - A quick-and-dirty alternative is `kubectl describe pod -n nato | grep -i image` to pull the image names.
- **Example output**
<img width="1066" height="97" alt="image" src="https://github.com/user-attachments/assets/6496f45b-a366-4898-88be-c8b5a0afff62" />

<br>

---

### Step 2 Scan Images for Vulnerabilities with Trivy

```bash
trivy image --severity HIGH,CRITICAL nginx:1.14.0
trivy image --severity HIGH,CRITICAL alpine:3.18
```

- **What this does** Runs Trivy against each target container image and filters the output via `--severity` to surface **only** `HIGH` and `CRITICAL` vulnerabilities.
- **What to look for** If you have multiple images, scan them one by one. Watch for an output table populated with findings and red-highlighted vulnerability counts—those are the images you need to flag.

> 💡 **Exam Pro-Tip** If you blank on the exact flag name, check the official Trivy docs link (usually provided in the exam environment) or grep the CLI help directly in your terminal:
> ```bash
> trivy --help | grep severity
> ```

- **Example output**
<img width="1337" height="582" alt="image" src="https://github.com/user-attachments/assets/e008543c-59a1-4f65-a7e1-51ecf26ca793" />
<img width="1611" height="637" alt="image" src="https://github.com/user-attachments/assets/a0beabb9-d2ab-432d-b49b-be52765f4748" />

<br>

---

### Step 3 Delete Pods Running Vulnerable Images

```bash
kubectl delete pod vulnerable-pod -n nato
```

- **What this does** Deletes the Pod(s) backed by any image that came back with `HIGH` or `CRITICAL` vulnerabilities.
- **Gotcha to watch out for** Always explicitly pass `-n nato` when deleting Pods. Skipping the namespace flag is the easiest way to accidentally nuke the wrong workload in a different namespace.
- **Example output**
<img width="572" height="52" alt="image" src="https://github.com/user-attachments/assets/8fb567c2-50f6-4faa-a4f3-0062931dc611" />

