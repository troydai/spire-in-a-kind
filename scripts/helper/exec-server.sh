#!/bin/sh

# Execute spire-agent CLI in a spire-agent container on any of the daemonset pods.
kubectl exec -n spire -c spire-server deployment/spire-server-deployment -- /opt/spire/bin/spire-server $*