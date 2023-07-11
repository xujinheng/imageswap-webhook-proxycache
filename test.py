#!/usr/bin/env python3

from kubernetes import client, config, utils
from datetime import datetime
import re
import yaml

def get_mapped_image(image, rules):
    z_xx_io = re.match("^(.*?\.io)\/.*$", image)
    z_two_slash = re.match("^.*?\/.*?\/.*$", image)
    if not z_xx_io and not z_two_slash:
        image = "docker.io/" + image
    z = re.match("^(.*?)\/(.*?)\/(.*)$", image)
    if z:
        registry = z.group(1)
        repo = z.group(2)
        image_name = z.group(3)
        swapped_registry = rules.get(registry, rules.get("default", ""))
        swapped_registry = registry if swapped_registry == "" else swapped_registry
        swapped_image = "/".join([swapped_registry, repo, image_name])
        return swapped_image
    z = re.match("^(.*?)\/(.*)$", image)
    if z:
        registry = z.group(1)
        image_name = z.group(2)
        if registry == "k8s.gcr.io":
            swapped_registry = rules.get(registry, rules.get("default", ""))
        else:
            swapped_registry = rules.get(registry + "/library", rules.get("default", ""))
        swapped_registry = registry if swapped_registry == "" else swapped_registry
        swapped_image = "/".join([swapped_registry, image_name])
        return swapped_image

def get_rules():
    rules = {}
    with open("imageswap.yaml", "r") as stream:
        for doc in yaml.safe_load_all(stream):
            if doc["metadata"]["name"] == "imageswap-maps":
                for line in filter(None, doc["data"]["maps"].split("\n")):
                    rules[line.split("::")[0]] = line.split("::")[1]
    return rules

RULES = get_rules()

config.load_kube_config()
v1 = client.CoreV1Api()

NAMESPACE = "imageswap-test-" + datetime.now().strftime("%Y%m%d-%H%M%S")

print("create namespace: {}".format(NAMESPACE))
metadata = {
    "name": NAMESPACE,
    "labels": {
        "k8s.twr.io/imageswap": "enabled",
    }
}
v1.create_namespace(body={"metadata": metadata})

# create
ORIGIN_IMAGES=[
    'nginx',
    'bitnami/nginx',
    'docker.io/nginx',
    'docker.io/bitnami/nginx',
    'index.docker.io/nginx',
    'index.docker.io/bitnami/nginx',
    'gcr.io/arrikto/nginx',
    'k8s.gcr.io/nginx',
    'ghcr.io/linuxcontainers/nginx',
    'quay.io/minio/minio',
    'registry.k8s.io/scheduler-plugins/controller:v0.25.7',
    'localhost:5000/vmware/kube-rbac-proxy:0.0.1',
    "docker.io/kubeflownotebookswg/poddefaults-webhook",
    "gcr.io/kubebuilder/kube-rbac-proxy:v0.4.0",
    "gcr.io/ml-pipeline/cache-deployer:2.0.0-alpha.3",
    "docker.io/istio/proxyv2:1.14.1",
    "gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:14415b204ea8d0567235143a6c3377f49cbd35f18dc84dfa4baa7695c2a9b53d",
    "gcr.io/knative-releases/knative.dev/serving/cmd/domain-mapping@sha256:23baa19322320f25a462568eded1276601ef67194883db9211e1ea24f21a0beb"
]

for index, name in enumerate(ORIGIN_IMAGES):
    print("create pod with image: {}".format(name))
    pod = client.V1Pod()
    pod.metadata = client.V1ObjectMeta(name="test-pod-" + str(index))
    container = client.V1Container(name="my-container-" + str(index), image=name)
    pod.spec = client.V1PodSpec(containers=[container])
    v1.create_namespaced_pod(namespace=NAMESPACE, body=pod)

input("Press Enter to check results and delete testing resources...")

# sleep
for index, name in enumerate(ORIGIN_IMAGES):
    pod = v1.read_namespaced_pod(name="test-pod-" + str(index), namespace=NAMESPACE)
    swapped_name = pod.spec.containers[0].image
    print(index)
    if swapped_name == get_mapped_image(name, RULES):
        print("✅[Passed]")
    else:
        print("❌[Failed]")
    print("- original: {}".format(name))
    print("- swapped: {}".format(swapped_name))
    print("- phase: {}".format(pod.status.phase))

# delete namespace
body = client.V1DeleteOptions()
v1.delete_namespace(name=NAMESPACE, body=body)