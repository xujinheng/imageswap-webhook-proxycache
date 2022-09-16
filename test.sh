#!/bin/bash

NAMESPACE=imageswap-testing$(date +'-%Y%m%d-%H%M')

ORIGIN_IMAGES=( \
    'nginx' \
    'bitnami/nginx' \
    'docker.io/nginx' \
    'docker.io/bitnami/nginx' \
    'index.docker.io/nginx' \
    'index.docker.io/bitnami/nginx' \
    'gcr.io/arrikto/nginx' \
    'k8s.gcr.io/nginx' \
    'ghcr.io/linuxcontainers/nginx' \
    'quay.io/minio/minio' \
    'localhost:5000/vmware/kube-rbac-proxy:0.0.1' \
    )

ANSWERS=( \
    'harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx' \
    'harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx' \
    'harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx' \
    'harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx' \
    'harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx' \
    'harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx' \
    'harbor-repo.vmware.com/gcr-proxy-cache/arrikto/nginx' \
    'harbor-repo.vmware.com/gcr-proxy-cache/google-containers/nginx' \
    'harbor-repo.vmware.com/ghcr-proxy-cache/linuxcontainers/nginx' \
    'quay.io/minio/minio' \
    'localhost:5000/vmware/kube-rbac-proxy:0.0.1' \
    )
    
echo "create testing namespace: ${NAMESPACE}"
kubectl create ns ${NAMESPACE}
kubectl label ns ${NAMESPACE} k8s.twr.io/imageswap=enabled

passed=0
failed=0

for ((i = 0; i < ${#ORIGIN_IMAGES[@]}; i++)); do
    echo "---"
    cat << EOF | kubectl apply -f -
---
apiVersion: v1
kind: Pod
metadata:
  name: test-pod${i}
  namespace: ${NAMESPACE}
spec:
  containers:
  - name: test-pod${i}
    image: ${ORIGIN_IMAGES[i]}
---
EOF
    swaped_image=$(kubectl get pod test-pod${i} -n ${NAMESPACE} -o=jsonpath='{.spec.containers[0].image}')
    if [[ ${swaped_image} == ${ANSWERS[i]} ]]; then
        echo "✅[Passed]"
        echo "Original: ${ORIGIN_IMAGES[i]}"
        echo "Swapped : ${swaped_image}"
        ((passed=passed+1))
    else
        echo "❌[Failed]"
        echo "Original: ${ORIGIN_IMAGES[i]}"
        echo "Swapped : ${swaped_image}"
        echo "Answer  : ${ANSWERS[i]}"
        ((failed=failed+1))
    fi
done

echo "---"
echo "passed: ${passed}"
echo "failed: ${failed}"

echo "delete testing namespace: ${NAMESPACE}"
kubectl delete ns ${NAMESPACE}