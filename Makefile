.PHONY: up

CLUSTER_NAME=spireiak # spire in a kind

up:
	@ kubectl cluster-info --context kind-spireiak
	@ kubectl apply -f k8s/namespaces.yaml
	@ kubectl apply -f k8s/spiffe
	@ kubectl apply -f k8s/workload

down:
	@ kubectl cluster-info --context kind-spireiak
	@ kubectl delete -f k8s/namespaces.yaml

cluster-up: cluster/kind-config.yaml
	@ kind create cluster --name ${CLUSTER_NAME} --config cluster/kind-config.yaml

cluster-down:
	kind delete cluster --name ${CLUSTER_NAME}

workload-up:
	@ kubectl apply -f k8s/namespaces.yaml
	@ kubectl apply -f k8s/workload

workload-down:
	@ kubectl delete -f k8s/workload
