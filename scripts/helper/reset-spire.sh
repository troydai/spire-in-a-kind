#!/bin/sh

kubectl delete ns spire
kubectl create ns spire
kubectl apply -f k8s/spiffe
