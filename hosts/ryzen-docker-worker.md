# Ryzen 5700G – Docker Worker

## Hardware Overview

- Board: ASRock B450 Pro4
- CPU: Ryzen 7 5700G
- RAM: 32 GB
- Storage:
  - 1× 1 TB NVMe SSD (with option for more via bifurcation card).

## Role

**Docker worker** for CPU-heavy backend containers:

- Heavy compute services that are not GPU-bound.
- Batch processing, build pipelines, or CI-like workloads.
- Offload from smaller nodes (HX310-ARR, etc.).

## Proxmox Node

- Node name: `pve-ryzen-docker` (placeholder).
- Management IP:
  - `10.10.200.50`

## Notes

Over time, more NVMe drives can be added (via bifurcation card) to support:
- multiple Docker data volumes,
- ephemeral scratch space for builds and processing.
