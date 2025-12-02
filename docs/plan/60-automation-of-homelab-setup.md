# Automation of the Homelab Setup

This document describes how automation will be used to install, configure, and maintain the homelab. The goal is to:
- Reduce manual, error-prone steps.
- Make rebuilds repeatable.
- Keep a clear separation between **planning** (docs) and **execution** (scripts).

## 1. Principles

- **Git-first**: All automation scripts, templates, and runbooks live in Git (this repo).
- **Idempotent where possible**: Running a script twice should not break the system.
- **Dry-run by default** for destructive operations:
  - Partitioning, ZFS pool creation, and mass changes must support a preview mode.
- **Small, composable scripts**:
  - One script per concern (e.g. “prepare Proxmox host”, “install PBS client”, “sync docs to NAS”).
- **Human in the loop for dangerous actions**:
  - Never fully automate disk wipes or firewall rule resets without explicit confirmation.

## 2. Scope of Automation

Automation will primarily cover:

- Proxmox host preparation:
  - Applying the community `ProxmoxVE` helper scripts.
  - Enabling recommended repositories and disabling enterprise nag screens (for homelab use).
  - Installing a minimal base tooling set (e.g. `vim`, `htop`, `zfsutils`, etc., where appropriate).
- Basic network configuration on Proxmox:
  - Ensuring the management bridge is correctly configured.
  - Later: applying VLAN-aware bridge setups from templates.
- Deployment of infrastructure services:
  - OPNsense VM on Qotom with PCI passthrough.
  - LXC/VM for Netboot.xyz, OpenWISP, Notifiarr, CUPS, config backup.
  - DB & password stack (Postgres, Vaultwarden, Wiki.js, Git service).
  - *ARR stack and supporting services.
  - AI-controller components (Open WebUI, vectorisation, vector DB, API manager).
- Backups and housekeeping:
  - Regular Git repo sync to NAS.
  - Periodic database dumps.
  - Cleanup of old logs or temporary working directories.

## 3. Directory Layout for Automation

Suggested layout (future):

```text
automation/
  README.md
  proxmox/
    bootstrap-host.sh
    apply-helper-scripts.sh
  network/
    generate-opnsense-aliases.sh
  backup/
    sync-git-ssot-to-nas.sh
  ai/
    queue-skeleton.md
```

Initially, this repo will only contain simple scripts and documentation. Over time, you can gradually evolve these into fully-fledged installers.

## 4. Safe vs Dangerous Automation

To limit the “blast radius”, scripts are divided conceptually into:

- **Safe**:
  - Listing resources.
  - Generating configs or templates.
  - Pulling backups from remote, not pushing.
  - Performing read-only health checks.

- **Dangerous**:
  - Formatting disks.
  - Creating/destroying ZFS pools.
  - Reconfiguring network interfaces/bridges.
  - Changing firewall rules in bulk.

Convention (to be applied when scripts are created):

- Safe scripts live under: `automation/*` with normal names.
- Scripts that can cause data loss or network outage must:
  - Live under a clearly named folder or with a `-dangerous` suffix.
  - Require a `--force` flag or interactive confirmation.
  - Support a `--dry-run` mode where possible.

## 5. Interaction with AI-Orchestrator

Long-term, the pve-8845hs AI-controller will:

- Read plans and runbooks from this repo and/or Wiki.js.
- Prepare “execution plans” for complex changes.
- Propose commands or scripts to run on Proxmox/hosts.
- Log what was executed and why.

In the short term:

- Automation is still human-driven:
  - You copy/paste commands from runbooks.
  - You run scripts manually from the `automation/` directory.
- The documentation (this file and future runbooks) must remain readable and executable **without** AI.

## 6. Next Steps

- Define a minimal `automation/` tree with:
  - `README.md` describing the above principles.
  - Skeleton script files with comments and `echo` placeholders.
- Link the automation steps to specific runbooks:
  - e.g. `docs/runbooks/runbook-001-proxmox-host-installation.md`:
    - Step X: run `automation/proxmox/bootstrap-host.sh`.
  - e.g. `docs/runbooks/runbook-002-opnsense-staging-to-production.md`:
    - Step Y: run network verification script.

Automation should make the system *simpler* to manage, not more magical. If a script cannot be understood by “future you” after 6 months, it needs better comments or should be split into smaller pieces.
