#!/bin/bash

ARGOCD_VERSION=v2.0.4
ARGOCD_NEW_PASSWORD=${1:-redhat123}
GIT_REPO_URL=https://github.com/alosadagrande/argocd.git
ARGOCD_REPO_NAME=cnf

oc create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml

oc wait -n argocd --for=condition=Ready pod/argocd-application-controller-0
oc -n argocd create route passthrough argocd-server --service=argocd-server --port=https --insecure-policy=Redirect
ARGO_PASSWORD=$(oc -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)

while true; do
 yes | argocd --insecure --grpc-web login argocd-server-argocd.apps.ericsson.lab.bos.redhat.com:443 --username admin --password ${ARGO_PASSWORD} 
 [[ $? -ne 0 ]] || break
 echo "Waiting for the route to be ready..."
 sleep 5
done

argocd account update-password --account admin --current-password "${ARGO_PASSWORD}" --new-password "${ARGOCD_NEW_PASSWORD}"

argocd repo add ${GIT_REPO_URL} --name ${ARGOCD_REPO_NAME}

echo "Fixing docker rate limit for redis"
oc patch deployment argocd-redis --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "quay.io/alosadag/redis:6.2.4-alpine" }]' 
oc wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-redis

echo "Restarting controller,server and repo-server pods after patching redis"
oc delete pod -lapp.kubernetes.io/name=argocd-application-controller
oc delete pod -lapp.kubernetes.io/name=argocd-repo-server
oc delete pod -lapp.kubernetes.io/name=argocd-server

oc wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server

echo "ArgoCD {$ARGOCD_VERSION} is ready to be used"
exit 0

