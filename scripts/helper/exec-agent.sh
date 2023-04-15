#!/bin/sh

# Execute spire-agent CLI in a spire-agent container on any of the daemonset pods.
kubectl exec -n spire2 -c spire-agent daemonset/spire-agent -- /opt/spire/bin/spire-agent $*