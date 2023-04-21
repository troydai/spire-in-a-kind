#!/bin/bash

NS=$1
echo "Exec bash on pod in namespace $NS"

POD=`kubectl get pod -n $NS -ojson | jq -r '.items[0].metadata.name'`
kubectl -it exec -n $NS -c toolbox $POD -- bash
