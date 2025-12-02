# Homelab Roadmap – Proxmox-Based Setup

This document tracks the high-level phases for building and stabilising the homelab.

## Phase 0 – Current State

- Existing OPNsense router in front.
- New OPNsense instance and staging network **behind** the existing router.
- GitHub repo `homelab-proxmox` is the current Single Source of Truth (SSoT).
- NAS (unRAID) available for:
  - file storage,
  - future Postgres backup host (cold / reporting),
  - Git repo backups (clone/pull).

## Phase 1 – Staging Network & Proxmox Hosts

Goal: All Proxmox hosts installed and reachable in a **flat staging network**.

- Use a simple flat network, e.g. `192.168.0.0/16`, routed by the *new* OPNsense.
- Assign IPs **already in their future /24 blocks**, e.g.:
  - `192.168.30.x`  → future `LAN-USER` (VLAN 30).
  - `192.168.20.x`  → future `LAN-IOT` (VLAN 20).
  - `192.168.90.x`  → future `LAN-VVE-CCTV` (VLAN 90).
  - `192.168.100–130.x` → future backend / storage / AI ranges.
  - `192.168.200.x` → future `MGMT` (VLAN 200).

At this stage there are **no VLANs** yet – just a /16 – but the addressing scheme already matches the later design.

Deliverables:
- All Proxmox hosts installed (Qotom, HX310-DB, HX310-ARR, CW-NAS, X99 AI-worker, Ryzen Docker worker).
- Each host has:
  - management IP in the future `192.168.200.0/24` block,
  - basic SSH and Proxmox web UI reachable in the staging network.
- GitHub repo updated with:
  - host inventory (`docs/plan/20-host-inventory.md`),
  - mapping from hardware → Proxmox node name.

## Phase 2 – New OPNsense in Front, Old Router Retired

Goal: Make the *new* OPNsense the primary router/firewall, replacing the current one.

- Move Ziggo modem / DHCP to the new OPNsense.
  - Expected downtime: limited to modem reset + DHCP switch.
- Keep the staging network addressing (`192.168.0.0/16`) during the cutover.
- Ensure:
  - Internet works for key clients.
  - All Proxmox nodes are reachable on their existing IPs.
  - Access to old router is no longer required for normal operations.

Deliverables:
- New OPNsense in front.
- Snapshots/backup of OPNsense config stored:
  - in Git (redacted),
  - on NAS (encrypted if needed).

## Phase 3 – Core Services on HX310-DB (SSoT + Passwords)

Goal: Bring up the “brains” of the homelab on the **HX310-DB** host.

Services (likely LXC or VM + Docker):

- PostgreSQL: main DB for internal services.
- Vaultwarden:
  - Central password manager for all credentials.
  - Later: backup instance or tested restore path on another host (e.g. Qotom).
- Wiki.js:
  - nice UI layer on top of Git-based docs,
  - internal knowledge base.
- Git service (Gitea / Forgejo / similar):
  - local Git hosting for when GitHub is not reachable.
  - Clone of `homelab-proxmox` and other key repos.

At this stage, **GitHub remains the SSoT**, with Wiki.js as a consumer. Later the relationship can be inverted if desired, but for now Git wins.

Deliverables:
- HX310-DB Proxmox node running:
  - DB VM/LXC,
  - Vaultwarden, Wiki.js, Git service.
- Basic backup plan:
  - daily `pg_dump` to NAS,
  - regular Git pushes,
  - Vaultwarden export/backups shipped off-host.

## Phase 4 – Network Segmentation (VLANs) Without Renumbering

Goal: Introduce VLANs and proper segmentation **without changing IP addresses**.

- Convert from `/16` to multiple `/24`s:
  - `VLAN 30` → `192.168.30.0/24` – primary user LAN.
  - `VLAN 20` → `192.168.20.0/24` – IoT (cameras, TV boxes, etc.).
  - `VLAN 90` → `192.168.90.0/24` – VvE CCTV + recorder.
  - `VLAN 100–130` → backend (Docker, DB, AI, storage).
  - `VLAN 200` → `192.168.200.0/24` – management.
  - `VLAN 40` → DMZ BSD/jails (mail, reverse proxy, VPN), planned but can be implemented later.
- Switch ports updated to trunk/access as required.
- OPNsense:
  - new VLAN interfaces with /24 masks,
  - associated firewall rules per segment.

Because the IPs were already chosen within the /24 blocks, the change is mostly:
  - netmask `/16 → /24`,
  - plus proper VLAN tagging and firewall rules.

Deliverables:
- VLAN design implemented as per `docs/plan/55-staging-network-and-vlan-transition.md`.
- Basic rules:
  - backend cannot talk directly to DMZ without using the right frontends,
  - all HTTP/HTTPS user access goes via frontend/reverse-proxy,
  - management only from trusted admin networks.

## Phase 5 – AI Controller (CW-NAS-AMD-FP7-20G)

Goal: Stand up the **AI-orchestrator/control-plane** on the CW-NAS with the 8845HS.

Responsibilities:
- “Bronze tier” AI:
  - fast, local, lower-precision reasoning.
  - queue/router for tasks.
- API gateway for:
  - “Gold tier” external AI calls (OpenRouter, OpenAI, etc.).
- Integration into:
  - Wiki.js / Git for context,
  - homelab automation (scripts, runbooks).

The AI worker (X99 + dual A770) is **not** always on.  
The orchestrator must:
- route jobs to:
  - Bronze (local),
  - Silver (worker, when on),
  - Gold (external API, when allowed).
- provide visibility in a queue/dashboard.

Deliverables:
- CW-NAS running:
  - Open WebUI or similar interface,
  - queue/worker-system,
  - simple dashboard of pending/running/completed jobs.

## Phase 6 – AI Worker (X99 Dual Xeon + 2× A770)

Goal: Provide **“Silver tier”** local AI compute for heavier jobs.

- Only powered on when needed (to save power/heat/noise).
- Loaded with:
  - coding/model tasks,
  - long-running retrieval/analysis jobs,
  - experiments that benefit from multiple A770 GPUs.

Routing:
- Bronze/Gold still handled by the controller.
- Silver jobs are queued until the worker is available, unless overridden.

Deliverables:
- Worker node reachable over backend network.
- Queue integration with the controller.
- Basic “job lifecycle” visible in a web UI (even if minimal).

## Phase 7 – Backup & Restore Strategy (including NAS Postgres)

Goal: Make data loss survivable, and restores boring.

- GitHub (SSoT) regularly cloned to:
  - local Git service (HX310-DB),
  - NAS (for cold backup).
- Postgres:
  - HX310-DB as primary,
  - NAS running a backup/restore-only Postgres:
    - used for test restores,
    - potential read-only analytics later.
- Vaultwarden:
  - primary instance on HX310-DB,
  - tested restore path on another node (e.g. Qotom),
  - periodic exports to NAS.
- AI data:
  - ZFS snapshots on AI-data pool,
  - periodic replication or archives to NAS.

Deliverables:
- `docs/plan/70-backup-and-restore-strategy.md` describing:
  - RPO/RTO per service,
  - how often backups run,
  - where they are stored,
  - how restores are tested.
