# SPIRE sandbox

This sandbox demonstrates how to set up mTLS communication between two Kubernetes workflows with SPIFFE/SPIRE and Envoy.

## Usage

The sandbox is built on a kind cluster in a local docker environment. Helm installs all the components based on their charts.

### Prerequisite

- [Install docker](https://docs.docker.com/engine/install/)
- [Install kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Install helm](https://helm.sh/docs/helm/helm_install/)

### Set up

    # Create a kind cluster
    $ make cluster-up
    
    # Set up SPIFFE/SPIRE server and agents
    $ make spire-up
    
    # Set up demonstrate workloads
    $ ./scripts/setup/create-workloads.sh

### Tear down

    # Clean up the workloads
    $ ./scripts/setup/delete-workloads.sh
    
    # Clean up the SPIFFE/SPIRE
    $ make spire-down
    
    # Remove the cluster
    $ make cluster-down

## In the box

The sandbox comprises two major parts: the spire server cluster and the demonstrating workloads.

### SPIRE Server

The first one is a templated SPIFFE/SPIRE server setup. It includes:

- CSI Driver that assists in injecting spire agent UDS path into pods.
- A pair of cluster roles and role bindings that grand spire agent and corresponding server permissions to visit the Kubernetes API server.
- A spire server deployment. The spire server is configured by a config file mounted from a config map. The root X.509 certificate and privates are also mounted from separated config maps and secrets. (More on how to regenerate the root CA later). The server is exposed through a Kubernetes service on the 8081 port.
- A pair of daemon sets that install SPIFFE CSI driver and spire agents on all the nodes. The spire agent is also configured through the config file mounted from the config map.

### Demonstrating workloads

A pair of gRPC servers and clients are set up for demonstration purposes. Their implementation is at [grpcbeacon](https://github.com/troydai/grpcbeacon).

The workloads are set up as follows:

- The *beacon* deployments and its Kubernetes service exposed a gRPC service.
- The *prober* deployments are pods contain a toolbox and envoy containers that allow the user to send secured traffic
- A pair of envoy proxies front both beacon and prober. The proxies are configured statically through the mounted config file. The probers send requests to port 7000 on localhost, which the local envoy listens to. The envoy then forwards requests to the upstream beacon service.
- The envoy proxies are configured to establish mTLS communication. The certifications and private keys are set up through its SDS with the local node’s spire agent UDS.
- Basic authorizations are configured in the envoy to reject client and server SPIFFE ID that is not allowed.
