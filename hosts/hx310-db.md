# OnLogic HX310-DB – Database and Core Services

## Hardware Overview

- Model: OnLogic HX310
- CPU: Intel J6426 (or similar, fanless)
- RAM: 64 GB
- Storage:
  - 1× 1 TB NVMe SSD
- Special:
  - Dual RS232 ports available for future integrations.

## Role

Primary host for:

- PostgreSQL (core database for internal services).
- Vaultwarden (password manager).
- Wiki.js (documentation frontend).
- Git service (Gitea / Forgejo / similar).

This host effectively runs the **brains** of the homelab.

## Proxmox Node

- Node name: `pve-hx310-db` (placeholder).
- Management IP:
  - `10.10.200.20` (in `VLAN 200` / management block).

## Planned Services

- `lxc-db` / `vm-db-core`:
  - Postgres instance for:
    - Vaultwarden
    - Wiki.js
    - other internal apps.

- `lxc-vaultwarden`:
  - Primary password manager.
  - Regular backups, later with a tested restore path on another node.

- `lxc-wikijs`:
  - Connected to Git SSoT.
  - Serves internal docs at e.g. `wiki.local.emesix.nl`.

- `lxc-git`:
  - Local Git remote (mirror/failover for GitHub).
  - Clones of important repos (`homelab-proxmox`, etc.).

Full details and LXC/VM layout will be captured in service-specific docs and runbooks.
