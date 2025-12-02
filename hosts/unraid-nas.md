# unRAID NAS – Storage and Backup

## Hardware Overview

- Board: ASRock B450 Pro4
- CPU: Ryzen 5 3600
- RAM: 32 GB
- Storage:
  - 1× 1 TB NVMe SSD
  - 8× 16 TB HDD (data array)

## Role

- Primary unRAID-based NAS for:
  - file storage,
  - NFS/SMB shares,
  - backups (VMs, containers, configurations),
  - media storage.
- Optional:
  - Usenet and BitTorrent downloaders (to keep noisy disk activity on the NAS).

## Future Database Role

- Host a **PostgreSQL instance** dedicated to:
  - receiving logical backups (`pg_dump`) from primary DBs.
  - being the target for test restores and reporting.
- This Postgres instance is **not** a primary for any live service; it is a backup/analytics host.

## Network

- Backend / storage network IP:
  - e.g. `10.10.130.10` (in `BACKEND-STORAGE` range).
- Optionally a management IP in the `10.10.200.x` management range.

Exact addressing and VLAN membership to be finalised once the segmentation is implemented.
