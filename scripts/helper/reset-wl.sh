#!/bin/sh

kubectl delete ns workload-ns
kubectl create ns workload-ns
kubectl apply -f k8s/workload
