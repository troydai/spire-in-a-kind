#!/bin/sh

TRUST_DOMAIN=spire-in-a-box.troydai.cc
CLUSTER=kind-cluster

EXISTING_ENTRIES=`kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server entry show -output json | jq -r '.entries[].id'`

echo "Deleting existing entries..."

for entry in $EXISTING_ENTRIES; do
    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server entry delete -entryID $entry
done
