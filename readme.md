# Flux Cluster

Manages a cluster using [Kluctl](https://kluctl.io/). 

## Setup

1. Setup a linux server. e.g. Using [Alpine Linux with ZFS root](https://github.com/psy0rz/alpinebox).
2. Setup a k0s cluster. k3s also possible, if load balancer and traefik are disabled so that they can be managed by this config.
3. Install Kluctl
4. Create a new YAML file defining the arguments described in /bootstrap/.kluctl.yml
5. `cd` into the bootstrap folder and execute `kluctl deploy -t local --args-from-file <YAML file>`
6. `cd` into the clusterinfra folder and execute `kluctl deploy -t local`
7. TODO: Install applications

### TODO

- kluctl supports gitops, but this is not yet enabled

## Useful commands/tools

- [k9s](https://k9scli.io/) provides a CLI tool to monitor and manage kubernetes
  - `:secrets` will switch to view secrets. `:pods` views pods.
  - Edit secrets (e.g. to manage manual secrets for email auth, certificate generation, etc.)

## Structure

- /bootstrat   
  Creates ConfigMaps and Secrets in the `homelab-config` namespace. Kluctl can refer to these configurations to deploy other resources. This is as an alternative to storing configs and secrets in the code repo directly (e.g. SOPs, etc).
- /clusterinfra   
  This defines steps to set up the minimal cluster, including load balancing, ingress, certificates, etc.
