# imageswap-webhook-harbor-proxycache

The project is tailored for VMware internal usage, based on https://github.com/phenixblue/imageswap-webhook. 

For every pod created in a Kubernetes cluster, the webhook automatically swap its image registry to:

- harbor-repo.vmware.com/dockerhub-proxy-cache
- harbor-repo.vmware.com/gcr-proxy-cache
- harbor-repo.vmware.com/ghcr-proxy-cache

## Getting started

### Deployment
Deploy imageswap webhook with default settings tailored for VMware internal usage:
```bash
# Deletion is necessary to avoid MutatingWebhookConfiguration updating failures
# see issue https://github.com/phenixblue/imageswap-webhook/issues/78
kubectl delete -f imageswap_deploy.yaml
kubectl delete MutatingWebhookConfiguration imageswap-webhook
kubectl apply -f imageswap_deploy.yaml
```

  
### Customize

Default settings
  - CLUSTER_WIDE: True
  - failurePolicy: Ignore
  - replicas: 3
  - proxymap enabled: dockerhub, gcr, ghcr

Modify settings in generate_yaml.sh and generate a new yaml file
```bash
./generate_yaml.sh
```

### Testing
Run test
```bash
./test.sh
```

My testing results
```yaml
create testing namespace: imageswap-testing-20220916-1441
namespace/imageswap-testing-20220916-1441 created
namespace/imageswap-testing-20220916-1441 labeled
---
pod/test-pod0 created
✅[Passed]
Original: nginx
Swapped : harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx
---
pod/test-pod1 created
✅[Passed]
Original: bitnami/nginx
Swapped : harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx
---
pod/test-pod2 created
❌[Failed]
Original: docker.io/nginx
Swapped : harbor-repo.vmware.com/dockerhub-proxy-cache/nginx
Answer  : harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx
---
pod/test-pod3 created
✅[Passed]
Original: docker.io/bitnami/nginx
Swapped : harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx
---
pod/test-pod4 created
❌[Failed]
Original: index.docker.io/nginx
Swapped : harbor-repo.vmware.com/dockerhub-proxy-cache/nginx
Answer  : harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx
---
pod/test-pod5 created
✅[Passed]
Original: index.docker.io/bitnami/nginx
Swapped : harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx
---
pod/test-pod6 created
✅[Passed]
Original: gcr.io/arrikto/nginx
Swapped : harbor-repo.vmware.com/gcr-proxy-cache/arrikto/nginx
---
pod/test-pod7 created
✅[Passed]
Original: k8s.gcr.io/nginx
Swapped : harbor-repo.vmware.com/gcr-proxy-cache/google-containers/nginx
---
pod/test-pod8 created
✅[Passed]
Original: ghcr.io/linuxcontainers/nginx
Swapped : harbor-repo.vmware.com/ghcr-proxy-cache/linuxcontainers/nginx
---
pod/test-pod9 created
✅[Passed]
Original: quay.io/minio/minio
Swapped : quay.io/minio/minio
---
pod/test-pod10 created
❌[Failed]
Original: localhost:5000/vmware/kube-rbac-proxy:0.0.1
Swapped : harbor-repo.vmware.com/dockerhub-proxy-cache/localhost:5000/vmware/kube-rbac-proxy:0.0.1
Answer  : localhost:5000/vmware/kube-rbac-proxy:0.0.1
---
passed: 8
failed: 3
delete testing namespace: imageswap-testing-20220916-1441
namespace "imageswap-testing-20220916-1441" deleted
```

See issue https://github.com/phenixblue/imageswap-webhook/issues/77 to track progress on above failures.
