# imageswap-webhook-harbor-proxycache

Image Swap Mutating Admission Webhook for Kubernetes. The project is tailored for VMware internal usage, based on https://github.com/phenixblue/imageswap-webhook. 

For every pod create in k8s cluster, the webhook automatically swap its image registry to:
- harbor-repo.vmware.com/dockerhub-proxy-cache
- harbor-repo.vmware.com/gcr-proxy-cache
- harbor-repo.vmware.com/ghcr-proxy-cache

## Getting started

### Deployment
Deploy imageswap webhook with default settings tailored for VMware internal usage:
```bash
kubectl apply -f imageswap_deploy.yaml --namespace=imageswap-system
```

  
### Customize

Default settings
  - CLUSTER_WIDE: True
  - failurePolicy: Ignore
  - replicas: 3
  - proxymap enabled: dockerhub, gcr, ghcr

Modify and generate new yaml
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
create testing namespace: imageswap-testing-20220827-0154
namespace/imageswap-testing-20220827-0154 created
namespace/imageswap-testing-20220827-0154 labeled
---
pod/test-pod0 created
✅[Passed]
Original: nginx
Swapped: harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx
---
pod/test-pod1 created
✅[Passed]
Original: bitnami/nginx
Swapped: harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx
---
pod/test-pod2 created
❌[Failed]
Original: docker.io/nginx
Swapped: harbor-repo.vmware.com/dockerhub-proxy-cache/nginx
Should be harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx
---
pod/test-pod3 created
✅[Passed]
Original: docker.io/bitnami/nginx
Swapped: harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx
---
pod/test-pod4 created
❌[Failed]
Original: index.docker.io/nginx
Swapped: harbor-repo.vmware.com/dockerhub-proxy-cache/nginx
Should be harbor-repo.vmware.com/dockerhub-proxy-cache/library/nginx
---
pod/test-pod5 created
✅[Passed]
Original: index.docker.io/bitnami/nginx
Swapped: harbor-repo.vmware.com/dockerhub-proxy-cache/bitnami/nginx
---
pod/test-pod6 created
✅[Passed]
Original: gcr.io/arrikto/nginx
Swapped: harbor-repo.vmware.com/gcr-proxy-cache/arrikto/nginx
---
pod/test-pod7 created
✅[Passed]
Original: k8s.gcr.io/nginx
Swapped: harbor-repo.vmware.com/gcr-proxy-cache/google-containers/nginx
---
pod/test-pod8 created
✅[Passed]
Original: ghcr.io/linuxcontainers/nginx
Swapped: harbor-repo.vmware.com/ghcr-proxy-cache/linuxcontainers/nginx
---
pod/test-pod9 created
✅[Passed]
Original: quay.io/minio/minio
Swapped: quay.io/minio/minio
passed: 8
failed: 2
delete testing namespace: imageswap-testing-20220827-0154
namespace "imageswap-testing-20220827-0154" deleted
```
