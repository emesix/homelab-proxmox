# Jingsha X99 Dual Xeon – AI Worker

## Hardware Overview

- Board: JINGSHA X99 D4 DUAL PRO
- CPUs: 2× Intel Xeon E5-2686v4
- RAM: 128 GB ECC
- GPUs: 2× Intel Arc A770
- Storage: (to be documented)
- Planned:
  - Dedicated NVMe for OS.
  - High-speed NVMe pool for models/checkpoints (if not already present).

## Role

- **AI Worker / Silver tier**:
  - Heavy local inference workloads.
  - Long-running tasks (code generation, analysis).
  - Model experiments that benefit from dual A770 GPUs.

The node is **not always online** to save power, heat, and noise.

## Proxmox Node

- Node name: `pve-x99-ai` (placeholder).
- Management IP:
  - `10.10.200.40`

## Integration

- Exposed through backend networks only.
- Receives jobs from the AI controller (CW-NAS).
- Should integrate with whatever queue/tooling is later chosen for AI orchestration.

Further details will be defined in AI-specific documentation.
