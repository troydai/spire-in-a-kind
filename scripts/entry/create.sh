#!/bin/sh

TRUST_DOMAIN=spire-in-a-box.troydai.cc
CLUSTER=kind-cluster

EXISTING_ENTRIES=`kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server entry show -output json | jq -r '.entries[].id'`

echo "Deleting existing entries..."

for entry in $EXISTING_ENTRIES; do
    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server entry delete -entryID $entry
done

echo "Creating node group ..."

kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
    entry create -node \
    -spiffeID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
    -selector k8s_psat:cluster:$CLUSTER

echo "Creating entries for server ..."

for name in red blue; do
    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
        entry create \
        -spiffeID spiffe://$TRUST_DOMAIN/wl/beacon/$name \
        -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
        -selector k8s:ns:beacon-$name \
        -selector k8s:sa:beacon-sa
done

echo "Creating entries for clients ..."

for name in alice bob charlie; do
    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server \
        entry create \
        -spiffeID spiffe://$TRUST_DOMAIN/wl/ns/$name/prober \
        -parentID spiffe://$TRUST_DOMAIN/ns/spire/sa/spire-agent \
        -selector k8s:ns:prober-$name \
        -selector k8s:sa:prober-sa
done
