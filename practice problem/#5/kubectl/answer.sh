
cat /home/candidate/KSSC00301/Dockerfile

cat /home/candidate/KSSC00301/deployment.yaml

k apply --dry-run=client -f /home/candidate/KSSC00301/deployment.yaml

trivy config /home/candidate/KSSC00301/
