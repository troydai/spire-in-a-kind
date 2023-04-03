.PHONY: up

CLUSTER_NAME=spireiak # spire in a kind

up:
	@ kubectl cluster-info --context kind-spireiak
	@ kubectl apply -f k8s/spire-server.yaml
	@ kubectl apply -f k8s/spire-agent.yaml

down:
	@ kubectl cluster-info --context kind-spireiak
	@ kubectl delete -f k8s/spire-agent.yaml
	@ kubectl delete -f k8s/spire-server.yaml

cluster-up: cluster/kind-config.yaml
	@ kind create cluster --name ${CLUSTER_NAME} --config cluster/kind-config.yaml

cluster-down:
	kind delete cluster --name ${CLUSTER_NAME}
