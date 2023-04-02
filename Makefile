.PHONY: up

CLUSTER_NAME=spireiak # spire in a kind

up:
	@ kubectl cluster-info --context kind-spireiak
	@ kubectl apply -f k8s/spire-server.yaml
	# @ kubectl apply -f k8s/agent-conf.yaml
	# @ kubectl apply -f k8s/spire-server.yaml
	# @ kubectl apply -f k8s/workloads.yaml

down:
	@ kubectl cluster-info --context kind-spireiak
	@ kubectl delete -f k8s/spire-server.yaml
	# @ kubectl delete -f k8s/workloads.yaml
	# @ kubectl delete -f k8s/spire-server.yaml
	# @ kubectl delete -f k8s/agent-conf.yaml
	# @ kubectl delete -f k8s/server-conf.yaml

cluster-up: cluster/kind-config.yaml
	@ kind create cluster --name ${CLUSTER_NAME} --config cluster/kind-config.yaml

cluster-down:
	kind delete cluster --name ${CLUSTER_NAME}
