#!/bin/sh

TRUST_DOMAIN=spire-in-a-box.troydai.cc

kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server agent list 
