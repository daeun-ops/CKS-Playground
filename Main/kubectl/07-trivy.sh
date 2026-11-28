trivy image nginx:1.27
trivy image --severity CRITICAL,HIGH nginx:1.27
trivy image --severity CRITICAL nginx:1.27 --quiet

#scan Dockerfile

trivy config Dockerfile
