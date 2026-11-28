alias k=kubectl
which trivy || curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

k create ns secure-app
mkdir -p /home/candidate/review

k create deploy rogue-deploy -n secure-app --image=nginx --replicas=2

k run legacy-web -n secure-app --image=nginx:1.14.0
k run clean-app -n secure-app --image=alpine:3.18 -- sleep 3600

cat <<EOF > /home/candidate/review/Dockerfile
FROM ubuntu:16.04
ADD config.tar.gz /etc/app/
USER root
CMD ["sleep", "3600"]
EOF

cat <<EOF > /home/candidate/review/api-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  namespace: secure-app
spec:
  serviceAccountName: default
  containers:
  - name: api
    image: busybox
    command: ["sleep", "3600"]
    securityContext:
      privileged: true
      readOnlyRootFilesystem: false
      runAsUser: 0
EOF
