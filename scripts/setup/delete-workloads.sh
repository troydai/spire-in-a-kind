#!/bin/bash

for name in red blue; do
    ns=beacon-$name
    helm list -n $ns -ojson | jq -r '.[0] | .name' | xargs helm uninstall -n $ns
done

for name in alice bob charlie; do
    ns=prober-$name
    helm list -n $ns -ojson | jq -r '.[0] | .name' | xargs helm uninstall -n $ns
done

EXISTING_ENTRIES=`kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server entry show -output json | jq -r '.entries[].id'`

echo "Deleting existing SPIRE entries..."

for entry in $EXISTING_ENTRIES; do
    kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server entry delete -entryID $entry
done