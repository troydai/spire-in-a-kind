#!/bin/sh

TRUST_DOMAIN=spire-in-a-box.troydai.cc

EXISTING_ENTRIES=`kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server entry show -output json | jq -r '.entries[].id'`

echo "Deleting existing entries..."

for entry in $EXISTING_ENTRIES; do
    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server entry delete -entryID $entry
done

echo "Creating entries ..."

# Create a node entry for all nodes in the kind cluster.
kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
    entry create -node \
    -spiffeID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
    -selector k8s_psat:cluster:kind-cluster

# Create workload entry for beacon workload
kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
    entry create \
    -spiffeID spiffe://$TRUST_DOMAIN/wl/beacon \
    -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
    -selector k8s:ns:beacon \
    -selector k8s:sa:beacon-sa

kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
    entry create \
    -spiffeID spiffe://$TRUST_DOMAIN/wl/ns/alice/prober \
    -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
    -selector k8s:ns:alice \
    -selector k8s:sa:prober-sa

kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
    entry create \
    -spiffeID spiffe://$TRUST_DOMAIN/wl/ns/bob/prober \
    -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
    -selector k8s:ns:bob \
    -selector k8s:sa:prober-sa
