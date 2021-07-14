oc create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml
oc -n argocd create route passthrough argocd-server --service=argocd-server --port=https --insecure-policy=Redirect
ARGO_PASSWORD=$(oc -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
argocd --insecure --grpc-web login argocd-server-argocd.apps.ericsson.lab.bos.redhat.com:443 --username admin --password ${ARGO_PASSWORD}
argocd account update-password --account admin --current-password "${ARGO_PASSWORD}" --new-password "redhat123"
argocd repo add https://github.com/alosadagrande/argocd.git --name cnf
