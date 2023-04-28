.PHONY: up

CLUSTER_NAME=spireiak # spire in a kind
SPIRE_NAMESPACE=spire

cluster-up: cluster/kind-config.yaml
	@ kind create cluster --name ${CLUSTER_NAME} --config cluster/kind-config.yaml
	@ helm install -g ./charts/prerequisites

cluster-down:
	kind delete cluster --name ${CLUSTER_NAME}

spire-up:
	@ helm install -g -n ${SPIRE_NAMESPACE} --wait --create-namespace ./charts/spire

spire-down:
	@ helm list -n ${SPIRE_NAMESPACE} -ojson | jq -r '.[] | .name' | xargs helm uninstall -n ${SPIRE_NAMESPACE} --wait
