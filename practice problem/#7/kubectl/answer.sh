k get pod nginx-pod -n test-system -o jsonpath='{.spec.serviceAccountName}' > /candidate/KSC00124.txt


cat /candidate/KSC00124.txt; echo


k get pod nginx-pod -n test-system -o yaml | grep -i serviceAccountName
echo "secret-reader-sa" > /candidate/KSC00124.txt



k create role dev-test-role \
  --verb=update \
  --resource=namespaces \
  -n test-system



  k create role dev-test-role \
  --verb=update \
  --resource=namespaces \
  -n test-system


k auth can-i update namespaces --as=system:serviceaccount:test-system:secret-reader-sa -n test-system

k auth can-i delete namespaces --as=system:serviceaccount:test-system:secret-reader-sa -n test-system
  
