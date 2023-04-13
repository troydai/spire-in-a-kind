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

log-prober:
	@ kubectl logs -f -n workload-ns deployment/prober-deployment -c prober

log-beacon:
	@ kubectl logs -f -n workload-ns deployment/beacon-deployment -c beacon

beaconup:
	@ helm install -n beacon --create-namespace -g charts/beacon

beacondown:
	@ helm list -n beacon -ojson | jq -r '.[] | .name' | xargs helm uninstall -n beacon

logs-beacon:
	@ kubectl get pod -nbeacon -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -nbeacon -f -c beacon

logs-beacon-proxy:
	@ kubectl get pod -nbeacon -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -nbeacon -f -c envoy

proberup:
	@ helm install -n alice --create-namespace -g charts/prober
	@ helm install -n bob --create-namespace -g charts/prober

proberdown:
	@ helm list -n alice -ojson | jq -r '.[] | .name' | xargs helm uninstall -n alice
	@ helm list -n bob -ojson | jq -r '.[] | .name' | xargs helm uninstall -n bob

logs-prober:
	@ kubectl get pod -nalice -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -nalice -f -c prober

logs-prober-proxy:
	@ kubectl get pod -nalice -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -nalice -f -c envoy
