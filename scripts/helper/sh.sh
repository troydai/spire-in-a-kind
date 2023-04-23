#!/bin/bash

# Find the first pod in the given namespace,
# and execute bash on the given container. If the contaienr is not given, it will
# execute on the first container.

[ -z "$1" ] && { echo "Usage: sh.sh <namespace>"; exit 1; }

NS=$1
echo "In namespace $NS"

POD=`kubectl get pod -n $NS -ojson | jq -r '.items[0].metadata.name'`
echo "Found pod $POD"

if [[ -z "$2" ]]; then
    kubectl -it exec -n $NS $POD -- bash
else
    kubectl -it exec -n $NS -c $2 $POD -- bash
fi
