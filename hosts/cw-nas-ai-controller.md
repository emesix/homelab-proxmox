# CW-NAS-AMD-FP7-20G – AI Controller

## Hardware Overview

- Board: CW-NAS-AMD-FP7-20G
- CPU: Ryzen 7 8845HS (onboard)
- RAM: 64 GB
- Storage:
  - 2× 512 GB NVMe SSD (planned ZFS mirror for root + configs).
  - Additional PCIe NVMe (2×2 TB) for AI data and vector DB (planned).

## Role

**AI Controller / Bronze tier**:

- Orchestrates AI jobs locally and to external APIs.
- Runs “small” local models for:
  - quick checks,
  - routing decisions,
  - summarisation,
  - glue logic.
- Hosts:
  - Open WebUI (or similar).
  - vectorisation / embedding service.
  - vector DB (Qdrant/pgvector/etc.).
  - AI/API manager/router.

This node is intended to be **always on** and power-efficient.

## Proxmox Node

- Node name: `pve-cwnas-ai` (placeholder).
- Management IP:
  - `10.10.200.30`

## Planned Storage Layout

- Root / config:
  - ZFS mirror on 2×512 GB NVMe.
- AI data:
  - ZFS mirror on 2×2 TB NVMe in PCIe x8 slot.
  - Datasets, vector DB, logs, checkpoints.

Further details will be determined in ZFS and AI-stack planning docs.
