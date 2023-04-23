NS=$1

kubectl get pod -n $NS -ojson | \
		jq -r '.items[0].metadata.name' | \
		xargs kubectl logs -n $NS -f -c $2