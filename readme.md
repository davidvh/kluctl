# Kluctl Cluster

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

## After install

- Connect to `https://homepage.<domain>` to see the list of services
- Open **LLDAP** to configure users.
  - Use the ldap-admin secret to find the admin user to add the first user.
  - Add users to the various groups to grant permission to the associated services.
  - Recommend adding another user account to the admin group rather than using the initial admin account.
- Open **Mealie** to do the initial configuration. After logging in with one of the LDAP accounts, skip the configuration.

## Useful commands/tools

- [k9s](https://k9scli.io/) provides a CLI tool to monitor and manage kubernetes
  - `:secrets` will switch to view secrets. `:pods` views pods.
  - Edit secrets (e.g. to manage manual secrets for email auth, certificate generation, etc.)
- [kompose](https://kompose.io/) to quickly convert docker compose files to kubernetes

## Structure

- /bootstrap   
  Creates ConfigMaps and Secrets in the `homelab-config` namespace. Kluctl can refer to these configurations to deploy other resources. This is as an alternative to storing configs and secrets in the code repo directly (e.g. SOPs, etc).
- /base/clusterinfra   
  This defines services for the minimal cluster, including load balancing, ingress, certificates, etc.
- /base/appsinfra  
  This defines services that support other applications. This includes user authentication, monitoring, and notifications.
- /apps  
  The applications. Most users will spend time interacting with these services.

## Base Services

- `homepage.<domain>` - Automatically includes browser pages for your services, plus some basic monitoring of the cluster
- `lldap.<domain>` - LDAP accounts. The admin account is randomly generated in the lldap-admin secret. Use this account to do the initial login and create user accounts to authenticate with other services.
- `mail.<domain>` - a local-only email server for `<username>@mail.<domain>`. Services will use this to send notifications. Computers/phones can be configured to connect to this endpoint via SMTP and IMAP to recieve the notifications.
- `grafana.<domain>` - Monitoring of the cluster and applications.

### TODO

- Should be possible to host a webmail frontend.
- Expose logs in grafana (Loki)
- Blocky install for automatic routing and ad blocking
- WireGuard install for automatic VPN support
- Apps:
  - Recipes: [Mealie](https://github.com/mealie-recipes/mealie/)
  - Personal CRM: [Monica](https://www.monicahq.com/)
  - Tasks: [Vikunja](https://vikunja.io/)
  - Notes: [Memos](https://www.usememos.com/)
  - Books: [AudioBookshelf](https://www.audiobookshelf.org/guides)
  - Comics/PDFs: [Kavita](https://www.kavitareader.com/)
  - Document archive: [Paperless-NGX](https://docs.paperless-ngx.com/)
  - Home inventory [HomeBox?](https://homebox.software/en/)
  - Photo archive: [Immich](https://immich.app/docs/overview/introduction)
  - File management: [FileBrowser](https://filebrowser.org/installation)
  - Videos [Jellyfin](https://jellyfin.org/) + [Samba](https://github.com/kubernetes-csi/csi-driver-smb?tab=readme-ov-file)
  - Archive DVDs [Handbrake](https://github.com/TheNickOfTime/handbrake-web)
  - Read later: [LinkWarden](https://docs.linkwarden.app/self-hosting/installation)
  - Home automation: [Home Assistant](https://www.home-assistant.io/)
  - AI (Ollama?)
- Add a bigger storage pool for media storage
- Define regular backups