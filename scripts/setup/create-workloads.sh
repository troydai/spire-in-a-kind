#!/bin/bash

TRUST_DOMAIN=spire-in-a-box.troydai.cc
CLUSTER=kind-cluster

echo "Creating SPIRE node group ..."

kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
    entry create -node \
    -spiffeID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
    -selector k8s_psat:cluster:$CLUSTER

for name in red blue; do
    ns=beacon-$name
    helm install -n $ns --create-namespace -g charts/beacon --set beacon.name=$name --values workloads/beacon/$name/values.yaml

    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
        entry create \
        -spiffeID spiffe://$TRUST_DOMAIN/wl/ns/$ns/beacon \
        -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
        -selector k8s:ns:$ns \
        -selector k8s:sa:beacon-sa
done

for name in alice bob charlie; do
    ns=prober-$name
	helm install -n $ns --create-namespace -g charts/prober --values workloads/prober/$name/values.yaml

    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
        entry create \
        -spiffeID spiffe://$TRUST_DOMAIN/wl/ns/$ns/prober \
        -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
        -selector k8s:ns:$ns \
        -selector k8s:sa:prober-sa
done
