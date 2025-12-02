# OnLogic HX310-ARR – Media / *ARR Host

## Hardware Overview

- Model: OnLogic HX310
- RAM: 32 GB
- Storage:
  - 1× 1 TB NVMe SSD
  - 1× 1 TB SATA SSD (M.2 form factor)
- Special:
  - Dual RS232 ports.

## Role

Primarily a Docker host for:

- *ARR stack (Radarr, Sonarr, Lidarr, etc.).
- Media indexers and frontends.
- Light, mostly-frontend containers that are not CPU-heavy.

This host focuses on **user-facing media services**, not heavy compute.

## Proxmox Node

- Node name: `pve-hx310-arr` (placeholder).
- Management IP:
  - `10.10.200.21`

## Planned Services

On top of Proxmox (LXC/VM + Docker):

- `docker-arr` stack:
  - Radarr
  - Sonarr
  - Lidarr
  - Supporting tooling (indexers, small services).

Data paths and NFS/SMB shares will be coordinated with the unRAID NAS and backend networks.
