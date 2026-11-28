kubectl config use-context immutable-cluster


k get pods -n prod -o custom-columns=NAME:.metadata.name,PRIVILEGED:.spec.containers[*].securityContext.privileged,READONLY_FS:.spec.containers[*].securityContext.readOnlyRootFilesystem


k get pod -n prod -o yaml | grep -iE 'name:|privileged|readOnlyRootFilesystem'


k delete pod cms nginx -n prod


k get pods -n prod
