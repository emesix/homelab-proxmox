# 45 – Storage Layout and ZFS Strategy

## Goal

Define a **repeatable pattern** for disks and ZFS across all Proxmox hosts so that:

- installs are predictable,
- backups & restores are simpler,
- “fast but risky” vs “safe but slower” storage is clearly separated.

This document is the bridge between ChatGPT design discussions and concrete runbooks / ADRs.

---

## Core Pattern

### Two tiers per host (where hardware allows)

1. **System / Config Pool (`rpool` or similar)**
   - ZFS **mirror** (RAID1).
   - Holds:
     - Proxmox system,
     - `/etc`-level config,
     - core VM/LXC metadata,
     - *small* critical services if really needed.
   - Goal: uptime & easy recovery.

2. **Fast / Workload Pool (`zfast` or similar)**
   - ZFS **RAID0** (or striped vdevs).
   - Holds:
     - VM disks for high-IO services,
     - Docker / container volumes,
     - AI models, caches, scratch space,
     - logs and other easily rebuildable data.
   - Goal: speed. We **accept** that failure = rebuild from backups.

In short:

- **Mirror** = safety and configuration.
- **RAID0** = performance and “I can re-deploy this if a disk explodes”.

---

## Host-by-Host Intent

> Exact disk sizes / brands can be filled in per host file; here we define the *pattern*.

### 1. `pve-qotom` – LAN / OPNsense / Infra

- Likely physical layout:
  - 2× NVMe SSDs (used as a mirrored boot / system pool).
- Strategy:
  - `rpool`: ZFS mirror for Proxmox + core infra VMs (OPNsense VM, management tools).
  - No separate `zfast` needed here; this box is more about reliability than raw IO.
- Note:
  - PCI passthrough of I226/X553 NICs to the OPNsense VM is handled in its own runbook.

### 2. `pve-hx310-db` – DB + Wiki + Vaultwarden + Git

- Physical:
  - 1× NVMe SSD,
  - 1× SATA SSD.
- Strategy:
  - `rpool`:
    - Either:
      - ZFS single-disk pool on NVMe (with frequent snapshots + remote backups), **or**
      - Small ZFS mirror NVMe ↔ SATA if write endurance is acceptable.
  - `zfast`:
    - Use remaining NVMe space as high-IO dataset for:
      - PostgreSQL datasets,
      - Wiki.js data,
      - Vaultwarden DB.
- Important:
  - DB backups go to NAS/unRAID via NFS/SMB (see `docs/plan/40-service-inventory-and-placement.md` for which services live here).

### 3. `pve-hx310-arr` – *ARR / Media Frontends

- Physical:
  - Same pattern as `pve-hx310-db` (1× NVMe + 1× SATA).
- Strategy:
  - `rpool`:
    - ZFS on the NVMe (system + configs).
  - `zfast`:
    - Dataset(s) for:
      - Docker volumes for the *ARR stack,
      - indexer databases,
      - temporary downloads.
  - Media library itself:
    - Lives on NAS; this node mostly handles metadata and download pipelines.

### 4. `pve-cwnas-ai` – AI Controller / Orchestrator

- Physical:
  - Multiple NVMe slots + linkage to NAS.
- Strategy:
  - `rpool`:
    - Mirror on two SSDs for Proxmox + controller stack (Open WebUI, orchestration tools, etc.).
  - `zfast`:
    - Stripe of the remaining fast SSDs for:
      - AI project directories,
      - small local models / embeddings,
      - temporary vector DB data (backed up or re-buildable).
- Note:
  - Large/archival models and datasets live on the NAS; this node caches what’s “hot”.

### 5. `pve-x99-ai` – AI Worker (dual A770 GPUs)

- Physical (as intended):
  - **Set A**: 2× SSDs → good for mirror (`rpool`).
  - **Set B**: 4× SSDs → good for RAID0 (`zfast`).
    - Historically: 4× 1 TB NVMe for AI workloads.
- Strategy:
  - `rpool`:
    - ZFS mirror on Set A.
  - `zfast`:
    - ZFS RAID0 on Set B for:
      - model weights,
      - inference caches,
      - experiment artifacts,
      - logs.
- Recovery approach:
  - If `zfast` dies, rebuild models / data from:
    - NAS,
    - Git,
    - container images.

### 6. `pve-ryzen-docker` – CPU-Heavy Docker Worker

- Physical (as discussed):
  - 4× NVMe intended for ZFS RAID0 / stripe.
- Strategy:
  - If the OS is Proxmox:
    - `rpool`:
      - Small mirror or single disk, depending on layout.
    - `zfast`:
      - 4-disk ZFS stripe for:
        - Docker volumes,
        - CI runners,
        - scratch databases.
  - This host is intentionally “ephemeral-sane”:
    - Configs in Git + runbooks,
    - actual workloads can be re-created.

---

## Backups & Snapshots

- **System / Config**:
  - Use Proxmox backups + ZFS snapshots on `rpool`.
  - For critical configs (OPNsense, Wiki.js, PostgreSQL schemas), keep:
    - regular exports,
    - Git-tracked configs where possible.

- **Workload / Fast Data**:
  - Snapshot frequently if cheap,
  - but design as “rebuildable”:
    - /var/lib/docker volumes,
    - model caches,
    - CI workspace.

---

## Links / Next Steps

- Add host-specific details in:
  - `hosts/*.md`,
  - `proxmox/cluster-layout.md` (already present).
- Related documents:
  - ADR-00X – **Storage Tiering Strategy** (to be written if this plan solidifies).
  - Runbook-001 – Proxmox host installation (referenced for how to partition disks).
  - `docs/plan/40-service-inventory-and-placement.md` – ties services to storage tiers.
