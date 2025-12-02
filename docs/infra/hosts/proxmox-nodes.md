# Proxmox Hypervisors – Hardware & Roles (November 2025)

This document describes the Proxmox nodes in the homelab and their intended roles.
It is meant to be the single source of truth for hardware, management IPs and
high-level workload placement.

> NOTE: All servers below run **Proxmox VE** as the host OS.  
> The only major infrastructure node that does **not** run Proxmox is `nas-main`.

## 1. Summary table

| Hostname        | Management IP   | Location / Form factor          | CPU / Platform (short)             | RAM (approx.) | Primary role(s)                          |
|-----------------|-----------------|---------------------------------|------------------------------------|---------------|------------------------------------------|
| `pve-qotom01`   | 192.168.10.11   | 1U Qotom appliance              | Intel Atom C3758R                  | 32 GB         | OPNsense VM (WAN/LAN) + small services   |
| `pve-hx310-db`  | 192.168.10.12   | OnLogic HX310 (fanless)        | Intel Elkhart Lake (J64xx-class)   | 64 GB         | DB / Wiki / Vaultwarden, etc.           |
| `pve-hx310-arr` | 192.168.10.13   | OnLogic HX310 (fanless)        | Intel Elkhart Lake (J64xx-class)   | 32 GB         | *ARR / media-related services           |
| `pve-5700g`     | 192.168.10.14   | Small form factor / tower      | AMD Ryzen 7 5700G-class APU        | TBD           | General workloads, Docker/LXC VMs       |
| `pve-8845hs`    | 192.168.10.15   | Mini PC / SFF                   | AMD Ryzen 7 8845HS                 | TBD           | Future workloads / experiments          |
| `pve-x2686-x2`  | 192.168.10.16   | 4U Jingsha X99 D4 DUAL PRO     | 2× Intel Xeon E5‑2686 v4           | 128 GB ECC    | AI worker (GPU), heavy compute          |

Where “TBD” is shown for RAM, the exact values can be filled in from the live systems
(`free -h`, `dmidecode -t memory`) once confirmed.

---

## 2. Node details

### 2.1 pve-qotom01 (Qotom 1U – router host)

- **Hostname:** `pve-qotom01.internal`
- **Management IP:** `192.168.10.11`
- **Hardware:**
  - Platform: Qotom 1U appliance
  - CPU: Intel Atom C3758R (8-core, low power)
  - RAM: 32 GB
  - Storage: 2× NVMe SSD in ZFS mirror (rpool)
  - NICs: multiple Intel i226 and 10 GbE X553 (for WAN/LAN separation and future VLANs)
- **Primary roles:**
  - Host OPNsense as a **VM** with PCIe passthrough / bridge of WAN/LAN NICs.
  - Optionally run a few lightweight infrastructure containers/VMs (e.g. monitoring, DNS helper).
- **Notes:**
  - This node is critical for internet connectivity; avoid overloading it with heavy workloads.
  - ZFS snapshots can be used as checkpoints before OPNsense upgrades.

### 2.2 pve-hx310-db (OnLogic HX310 – DB / Wiki / Vaultwarden)

- **Hostname:** `pve-hx310-db.internal`
- **Management IP:** `192.168.10.12`
- **Hardware:**
  - Platform: OnLogic HX310 (fanless industrial)
  - CPU: Intel Elkhart Lake J64xx-class (e.g. J6426)
  - RAM: ~64 GB (to be confirmed)
  - Storage:
    - 1× NVMe SSD (OS / Proxmox / VMs)
    - 1× SATA SSD (can be used for DB data / backups / ZFS mirror)
- **Primary roles (via VMs/CTs):**
  - PostgreSQL (central DB)
  - Wiki.js
  - Vaultwarden
  - Supporting services like Notifiarr, small automations
- **Notes:**
  - This node should prioritise reliability and I/O for databases.
  - Keep heavy CPU/GPU workloads off this box; use `pve-x2686-x2` instead.

### 2.3 pve-hx310-arr (OnLogic HX310 – *ARR / media)

- **Hostname:** `pve-hx310-arr.internal`
- **Management IP:** `192.168.10.13`
- **Hardware:**
  - Platform: OnLogic HX310 (fanless)
  - CPU: Intel Elkhart Lake J64xx-class (e.g. J6424)
  - RAM: ~32 GB
  - Storage:
    - 1× NVMe SSD (OS / Proxmox / media stack)
- **Primary roles (via VMs/CTs):**
  - *ARR stack (Sonarr, Radarr, Lidarr, Prowlarr, etc.)
  - Download clients, indexer-related tools
  - Possibly front-end containers that talk to NAS storage
- **Notes:**
  - Large media files should live on the NAS (`nas-main`); this node can mount them via NFS/SMB.

### 2.4 pve-5700g (Ryzen APU node – general workloads)

- **Hostname:** `pve-5700g.internal`
- **Management IP:** `192.168.10.14`
- **Hardware (current understanding):**
  - Platform: ATX/mATX tower or SFF system
  - CPU: AMD Ryzen 7 5700G-class APU
  - RAM: TBD
  - Storage: combination of NVMe SSDs (e.g. for rpool and data pools)
- **Primary roles (via VMs/CTs):**
  - General-purpose Linux workloads
  - Docker/LXC-based stacks that do not require GPU or extreme memory
  - Potentially `docker-main` or other orchestrator-like services
- **Notes:**
  - Exact disk layout (ZFS mirror/RAIDZ, data pools) should be documented once final.

### 2.5 pve-8845hs (Ryzen 7 8845HS Mini-PC)

- **Hostname:** `pve-8845hs.internal`
- **Management IP:** `192.168.10.15`
- **Hardware (current understanding):**
  - Platform: compact Mini-PC with Ryzen 7 8845HS
  - RAM: TBD
  - Storage: NVMe SSD(s)
- **Primary roles (via VMs/CTs):**
  - Flexible lab node for new workloads
  - Potential candidate for GPU-less AI orchestration, CI runners, or temporary experiments
- **Notes:**
  - Exact role can evolve; hardware and IP are fixed, services are flexible.

### 2.6 pve-x2686-x2 (Jingsha X99 dual Xeon – AI worker)

- **Hostname:** `pve-x2686-x2.internal`
- **Management IP:** `192.168.10.16`
- **Hardware:**
  - Motherboard: JINGSHA X99 D4 DUAL PRO
  - CPUs: 2× Intel Xeon E5‑2686 v4
  - RAM: 4× 32 GB ECC = 128 GB
  - Storage (planned layout):
    - 2× 512 GB NVMe in ZFS mirror for root/boot (`rpool`)
    - 4× 1 TB NVMe in ZFS RAID0 (or striped pool) for AI scratch / model storage (`/LocalAI`-style)
  - GPUs:
    - 1× Intel Arc A770 (initially)
    - Potential future second GPU
- **Primary roles (via VMs/CTs):**
  - AI worker VM(s) with GPU passthrough (e.g. Ubuntu-based:
    - Local model serving (IPEX-LLM, vLLM, Ollama, etc.)
    - Embedding generation and RAG pipelines
  - Heavy compute jobs and batch tasks
- **Notes:**
  - Proxmox hosts the hypervisor; AI stacks live inside dedicated VMs/CTs.
  - For simplicity, start with **one** large AI worker VM with full GPU passthrough.

---

## 3. Non-Proxmox infrastructure: nas-main

Although not a Proxmox node, `nas-main` is central to the homelab:

- **Hostname:** `nas-main.internal`
- **IP address:** `192.168.20.11`
- **Role:**
  - ZFS or similar storage platform
  - Export NFS/SMB/iSCSI to Proxmox (VM disks, backups, media)
  - Optionally host lightweight services like a Git remote or backup tooling
- **OS:** Dedicated NAS-OS (e.g. TrueNAS, OMV, or a custom Linux NAS).
- **Notes:**
  - This host should remain as simple and stable as possible.
  - All heavier application logic is intended to run on Proxmox nodes, not directly on the NAS.

---

## 4. Future updates

- Fill in exact RAM sizes for the Ryzen-based nodes once confirmed.
- Add a section mapping “service → VM/CT → Proxmox node”.
- Add disk layout details for each node once ZFS pools are final.