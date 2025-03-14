# Flux Cluster

Manages a cluster using [Kluctl](https://kluctl.io/). 

## Setup

1. Setup a linux server, not using a ZFS root. e.g. by installing DietPI to a usb drive and mounting a ZFS drive to /var/lib/rancher (`zfs set mountpoint=/var/lib/rancher rpool/rancher`)
2. Create a new ZFS dataset for OpenEBS zfs-local CSI to use for volumes. e.g. `zfs create rpool/openebs` and `zfs set mountpoint=none rpool/openebs`
3. Setup a k0s cluster. k3s also possible, if load balancer and traefik are disabled so that they can be managed by this config.
4. Install Kluctl
5. Create a new YAML file defining the arguments described in /bootstrap/.kluctl.yml
6. Execute `.\deploy.ps1 -BootstrapFile <YAML file>` to set the bootstrap values in the cluster
7. Execute `.\deploy.ps1 -Targets base` to deploy the basic infrastructure
8. Execute `.\deploy.ps1 -Targets apps` (or other sub-targets) to deploy applications

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

## Base Services

- `homepage.<domain>` - Automatically includes browser pages for your services, plus some basic monitoring of the cluster
- `lldap.<domain>` - LDAP accounts. The admin account is randomly generated in the lldap-admin secret. Use this account to do the initial login and create user accounts to authenticate with other services.
- `mail.<domain>` - a local-only email server for `<username>@mail.<domain>`. Services will use this to send notifications. Computers/phones can be configured to connect to this endpoint for SMTP and IMAP.

### TODO

- Base initialization needs to be broken down more to support rollout from scratch. Currently tries to use secrets before they are created.
- Should be possible to host a webmail frontend.