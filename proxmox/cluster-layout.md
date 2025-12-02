# Proxmox Cluster Layout

## Nodes

- `pve-qotom` – LAN management / OPNsense VM / infra services.
- `pve-hx310-db` – DB + Vaultwarden + Wiki.js + Git.
- `pve-hx310-arr` – *ARR / media and light Docker frontends.
- `pve-8845hs` (hoofdstuk) – AI controller / orchestrator.
- `pve-x99-ai` – AI worker (dual A770 GPUs).
- `pve-ryzen-docker` – CPU-heavy Docker worker.

## Cluster Strategy

- Single Proxmox cluster containing all nodes:
  - simplifies management,
  - allows live migration where hardware is compatible.
- Nodes may differ in features (GPU, storage), so not all VMs are migratable everywhere.

## Storage Overview

- Each node uses its own local storage for performance-critical workloads.
- Backups and longer-term storage are hosted on the unRAID NAS, via:
  - NFS/SMB mounts,
  - or Proxmox backup server (later, if introduced).

## OPNsense VM Placement

- The OPNsense VM runs on `pve-qotom`.
- Critical: avoid unnecessary Proxmox reboots while OPNsense is the main router.
- Consider:
  - a basic HA strategy or at least fast restore plan for OPNsense.

Further details will be captured in network and runbook documents.
