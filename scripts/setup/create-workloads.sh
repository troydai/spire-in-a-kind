#!/bin/bash

# Delete resources first 
WORKDIR=$(dirname "$0")
$WORKDIR/delete-workloads.sh

# Create resources
TRUST_DOMAIN=spire-in-a-box.troydai.cc
CLUSTER=kind-cluster

echo "Creating SPIRE node group ..."

kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
    entry create -node \
    -spiffeID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
    -selector k8s_psat:cluster:$CLUSTER

for name in red blue; do
    ns=httpbin-$name
    helm install -n $ns --create-namespace -g charts/httpbin --values workloads/httpbin/$name/values.yaml

    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
        entry create \
        -spiffeID spiffe://$TRUST_DOMAIN/wl/ns/$ns/httpbin \
        -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
        -selector k8s:ns:$ns \
        -selector k8s:sa:httpbin-sa
done

for name in alice bob charlie; do
    ns=caller-$name
	helm install -n $ns --create-namespace -g charts/caller

    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
        entry create \
        -spiffeID spiffe://$TRUST_DOMAIN/wl/ns/$ns/toolbox \
        -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
        -selector k8s:ns:$ns \
        -selector k8s:sa:caller-sa
done
