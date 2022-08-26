#!/bin/bash

### Scope: cluster wide or namespace wide
CLUSTER_WIDE="True"

### To enable image swap for namespace ${certain-namespace}:
### kubectl label ns ${certain-namespace} k8s.twr.io/imageswap=enabled
# CLUSTER_WIDE="False"

### failurePolicy defines how unrecognized errors and timeout errors from the admission webhook are handled. 
# export FAILUREPOLICY=Fail
export FAILUREPOLICY=Ignore

export REPLICAS=3

function DUMP_PROXYMAP() {
    echo '
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: imageswap-maps
  namespace: imageswap-system
data:
  maps: |
    default::
    docker.io::harbor-repo.vmware.com/dockerhub-proxy-cache
    docker.io/library::harbor-repo.vmware.com/dockerhub-proxy-cache/library
    index.docker.io::harbor-repo.vmware.com/dockerhub-proxy-cache
    index.docker.io/library::harbor-repo.vmware.com/dockerhub-proxy-cache/library
    k8s.gcr.io::harbor-repo.vmware.com/gcr-proxy-cache/google-containers
    gcr.io::harbor-repo.vmware.com/gcr-proxy-cache
    ghcr.io::harbor-repo.vmware.com/ghcr-proxy-cache
' >> $1
}

####################################################

ping -c 1 proxy.vmware.com &> /dev/null
if [ $? -eq 0 ]; then
    echo "VMware proxy enabled."
    export http_proxy="http://proxy.vmware.com:3128"
    export https_proxy="http://proxy.vmware.com:3128"
    export HTTP_PROXY="http://proxy.vmware.com:3128"
    export HTTPS_PROXY="http://proxy.vmware.com:3128"
fi

if [ -e 'imageswap-webhook' ]; then
    echo "imageswap-webhook already exists, skip git clone!"
else
    git clone git@github.com:phenixblue/imageswap-webhook.git
fi

yq version &> /dev/null
if [[ ! $? == '0' ]]; then
    echo "install yq"
    sudo snap install yq 
fi

# add harbor-repo.vmware.com/dockerhub-proxy-cache/ if not yet
deploy_file=imageswap-webhook/deploy/manifests/imageswap-deploy.yaml
if [[ $( yq '.spec.template.spec.initContainers[].image == "harbor-repo.vmware.com*" ' ${deploy_file} ) == "false" ]]; then
    yq -i '.spec.template.spec.initContainers[].image |= "harbor-repo.vmware.com/dockerhub-proxy-cache/" + . ' ${deploy_file}
fi
if [[ $( yq '.spec.template.spec.containers[].image == "harbor-repo.vmware.com*" ' ${deploy_file} ) == "false" ]]; then
    yq -i '.spec.template.spec.containers[].image |= "harbor-repo.vmware.com/dockerhub-proxy-cache/" + . ' ${deploy_file}
fi

if [[ ${CLUSTER_WIDE} == 'True' ]]; then
    yq -i 'del(.webhooks[].namespaceSelector)' imageswap-webhook/deploy/manifests/imageswap-mwc.yaml
fi

yq -i '.webhooks[].failurePolicy = env(FAILUREPOLICY)' imageswap-webhook/deploy/manifests/imageswap-mwc.yaml
yq -i '.spec.replicas = env(REPLICAS)' imageswap-webhook/deploy/overlays/production/deploy-patch.yaml

kubectl kustomize imageswap-webhook/deploy/overlays/production > imageswap_deploy.yaml
DUMP_PROXYMAP imageswap_deploy.yaml

echo "Yaml file generated at imageswap_deploy.yaml, to deploy:"
echo "kubectl apply -f imageswap_deploy.yaml --namespace=imageswap-system"