# imageswap-webhook-proxycache

The project is tailored for vSphere TKG usage, based on https://github.com/phenixblue/imageswap-webhook. 

For every pod created in a Kubernetes cluster, the webhook automatically swap its image registry to the configured proxy.

## Getting started

### Deployment
1. [Optional] Edit imageswap-maps with mirrors in https://github.com/eryajf/Thanks-Mirror#mirrors-66
2. Deploy imageswap webhook:
```bash
# Deletion is necessary to avoid MutatingWebhookConfiguration updating failures
# see issue https://github.com/phenixblue/imageswap-webhook/issues/78
kubectl delete -f imageswap.yaml --ignore-not-found=true
kubectl delete MutatingWebhookConfiguration imageswap-webhook --ignore-not-found=true
kubectl apply -f imageswap.yaml
```

### Testing
Run test
```bash
python3 test.py
```

My testing results
```yaml
create namespace: imageswap-test-20230623-172133
create pod with image: nginx
create pod with image: bitnami/nginx
create pod with image: docker.io/nginx
create pod with image: docker.io/bitnami/nginx
create pod with image: index.docker.io/nginx
create pod with image: index.docker.io/bitnami/nginx
create pod with image: gcr.io/arrikto/nginx
create pod with image: k8s.gcr.io/nginx
create pod with image: ghcr.io/linuxcontainers/nginx
create pod with image: quay.io/minio/minio
create pod with image: localhost:5000/vmware/kube-rbac-proxy:0.0.1
create pod with image: docker.io/kubeflownotebookswg/poddefaults-webhook
create pod with image: gcr.io/kubebuilder/kube-rbac-proxy:v0.4.0
create pod with image: gcr.io/ml-pipeline/cache-deployer:2.0.0-alpha.3
create pod with image: docker.io/istio/proxyv2:1.14.1
create pod with image: gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:14415b204ea8d0567235143a6c3377f49cbd35f18dc84dfa4baa7695c2a9b53d
create pod with image: gcr.io/knative-releases/knative.dev/serving/cmd/domain-mapping@sha256:23baa19322320f25a462568eded1276601ef67194883db9211e1ea24f21a0beb
Press Enter to check results and delete testing resources...
0
✅[Passed]
- original: nginx
- swapped: docker.nju.edu.cn/nginx
- phase: Running
1
✅[Passed]
- original: bitnami/nginx
- swapped: docker.nju.edu.cn/bitnami/nginx
- phase: Running
2
✅[Passed]
- original: docker.io/nginx
- swapped: docker.nju.edu.cn/nginx
- phase: Running
3
✅[Passed]
- original: docker.io/bitnami/nginx
- swapped: docker.nju.edu.cn/bitnami/nginx
- phase: Running
4
✅[Passed]
- original: index.docker.io/nginx
- swapped: docker.nju.edu.cn/nginx
- phase: Running
5
✅[Passed]
- original: index.docker.io/bitnami/nginx
- swapped: docker.nju.edu.cn/bitnami/nginx
- phase: Running
6
✅[Passed]
- original: gcr.io/arrikto/nginx
- swapped: gcr.nju.edu.cn/arrikto/nginx
- phase: Running
7
✅[Passed]
- original: k8s.gcr.io/nginx
- swapped: gcr.nju.edu.cn/google-containers/nginx
- phase: Running
8
✅[Passed]
- original: ghcr.io/linuxcontainers/nginx
- swapped: ghcr.nju.edu.cn/linuxcontainers/nginx
- phase: Running
9
✅[Passed]
- original: quay.io/minio/minio
- swapped: quay.nju.edu.cn/minio/minio
- phase: Running
10
❌[Failed]
- original: localhost:5000/vmware/kube-rbac-proxy:0.0.1
- swapped: docker.nju.edu.cn/localhost:5000/vmware/kube-rbac-proxy:0.0.1
- phase: Pending
11
✅[Passed]
- original: docker.io/kubeflownotebookswg/poddefaults-webhook
- swapped: docker.nju.edu.cn/kubeflownotebookswg/poddefaults-webhook
- phase: Running
12
✅[Passed]
- original: gcr.io/kubebuilder/kube-rbac-proxy:v0.4.0
- swapped: gcr.nju.edu.cn/kubebuilder/kube-rbac-proxy:v0.4.0
- phase: Running
13
✅[Passed]
- original: gcr.io/ml-pipeline/cache-deployer:2.0.0-alpha.3
- swapped: gcr.nju.edu.cn/ml-pipeline/cache-deployer:2.0.0-alpha.3
- phase: Running
14
✅[Passed]
- original: docker.io/istio/proxyv2:1.14.1
- swapped: docker.nju.edu.cn/istio/proxyv2:1.14.1
- phase: Running
15
✅[Passed]
- original: gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:14415b204ea8d0567235143a6c3377f49cbd35f18dc84dfa4baa7695c2a9b53d
- swapped: gcr.nju.edu.cn/knative-releases/knative.dev/serving/cmd/queue@sha256:14415b204ea8d0567235143a6c3377f49cbd35f18dc84dfa4baa7695c2a9b53d
- phase: Running
16
✅[Passed]
- original: gcr.io/knative-releases/knative.dev/serving/cmd/domain-mapping@sha256:23baa19322320f25a462568eded1276601ef67194883db9211e1ea24f21a0beb
- swapped: gcr.nju.edu.cn/knative-releases/knative.dev/serving/cmd/domain-mapping@sha256:23baa19322320f25a462568eded1276601ef67194883db9211e1ea24f21a0beb
- phase: Running
```
