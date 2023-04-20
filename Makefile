.PHONY: up

CLUSTER_NAME=spireiak # spire in a kind
SPIRE_NAMESPACE=spire

cluster-up: cluster/kind-config.yaml
	@ kind create cluster --name ${CLUSTER_NAME} --config cluster/kind-config.yaml
	@ helm install -g ./charts/prerequisites
	@ ./scripts/entry/create.sh

cluster-down:
	kind delete cluster --name ${CLUSTER_NAME}

beacon-up:
	@ helm install -n beacon --create-namespace -g charts/beacon --wait

beacon-down:
	@ helm list -n beacon -ojson | jq -r '.[] | .name' | xargs helm uninstall -n beacon

beacon-log:
	@ kubectl get pod -nbeacon -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -nbeacon -f -c beacon

beacon-log-proxy:
	@ kubectl get pod -nbeacon -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -nbeacon -f -c envoy

prober-up:
	@ helm install -n alice --create-namespace -g charts/prober
	@ helm install -n bob --create-namespace -g charts/prober
	@ helm install -n charlie --create-namespace -g charts/prober

prober-down:
	@ helm list -n alice -ojson | jq -r '.[] | .name' | xargs helm uninstall -n alice
	@ helm list -n bob -ojson | jq -r '.[] | .name' | xargs helm uninstall -n bob
	@ helm list -n charlie -ojson | jq -r '.[] | .name' | xargs helm uninstall -n charlie

prober-log:
	@ kubectl get pod -nalice -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -nalice -f -c prober

prober-log-proxy:
	@ kubectl get pod -nalice -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -nalice -f -c envoy

spire-up:
	@ helm install -g -n ${SPIRE_NAMESPACE} --create-namespace ./charts/spire

spire-down:
	@ helm list -n ${SPIRE_NAMESPACE} -ojson | jq -r '.[] | .name' | xargs helm uninstall -n ${SPIRE_NAMESPACE} --wait

spire-upgrade:
	@ helm list -n ${SPIRE_NAMESPACE} -ojson | jq -r '.[] | .name' | xargs -I {} helm upgrade -n ${SPIRE_NAMESPACE} {}" ./charts/spire

spire-up-dryrun:
	@ helm install -g -n ${SPIRE_NAMESPACE}-dryrun --dry-run ./charts/spire
