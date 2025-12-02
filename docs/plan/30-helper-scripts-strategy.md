# Helper Scripts Strategy (Proxmox VE Helper-Scripts)

## Purpose

This document defines **how and when** the Proxmox VE Helper-Scripts
(community-scripts) are used in the homelab. They provide convenience and
automation for common Proxmox tasks, but they are:

- Community-maintained (not official Proxmox tools).
- Opinionated in what they change (especially repository and template
  configuration).
- Subject to compatibility with specific Proxmox + Debian versions.

The goal is to use them in a **controlled and documented** way, especially
during:

- Initial host configuration (staging network).
- Later service rollout (LXC-based apps, monitoring, etc.).
- Optional quality-of-life improvements (Netdata, script launcher, etc.).

## 1. Overview of Helper-Scripts

The Proxmox VE Helper-Scripts collection offers many scripts for installing
applications, configuring repositories, managing LXC containers and more.

Key points:

- Primary website: community-scripts ProxmoxVE page.
- Most scripts are invoked with a one-liner:

  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/<path>/<script>.sh)"
  ```

- There is **no official endorsement by Proxmox**; they are community
  scripts.

For each host role, we decide which scripts may be used during:

- Stage 0/1: initial OS install and repo fix.
- Stage 2+: services and extra tooling.

## 2. Scripts Used in the Configuration Phase

### 2.1. PVE Post Install

**Goal:**  
Standardize Proxmox repository configuration and basic post-install steps.

**When:**

- On **every new Proxmox VE node**, shortly after a clean installation.
- While the node is still in the staging network (`10.10.10.x`).

**What it typically does:**

- Disable Proxmox Enterprise repository if not using a paid subscription.
- Enable the `pve-no-subscription` repository.
- Add or correct standard Debian sources (matching your Proxmox/Debian
  version).
- Optionally remove the subscription “nag” popup (depending on options).

**Where:**

- Qotom (cluster seed node).
- HX310-1 / HX310-2.
- B450 Docker worker.
- X99 AI worker.
- CW-NAS-AMD AI controller.
- Any future Proxmox nodes.

**Notes:**

- Always check the script’s description to confirm **supported PVE/Debian
  versions** before using.
- After running, always perform:

  ```bash
  apt update
  apt full-upgrade -y
  ```

### 2.2. PVEScripts-Local (PVE Scripts Local)

**Goal:**  
Provide a **local web UI** and menu for discovering and running helper
scripts without visiting the main website every time.

**When:**

- After the seed node is stable (Qotom), and at least one admin user exists.
- Optionally later on other nodes, but one central installation is often
  enough.

**Where:**

- Recommended on the Qotom node as the main “script execution hub”.
- Optionally on other nodes if you want per-node script dashboards.

**What it does:**

- Deploys a small web application (usually in an LXC or on a node) that
  lists available scripts.
- Integrates with the Proxmox environment so you can trigger scripts easily.

**Notes:**

- Prefer installing it in a dedicated Debian LXC (for isolation).
- Remember: running scripts that touch system configuration still affects
  the selected host; treat it like any admin tool.

### 2.3. Kernel Pin

**Goal:**  
Pin a known-good Proxmox kernel on critical nodes so that updates don’t
accidentally break GPU drivers, ZFS or other sensitive components.

**When:**

- **Not** during the very first boot.
- After:
  - The cluster is formed and stable.
  - You have verified that a particular kernel version behaves correctly
    under your workloads (e.g. Arc GPUs, ZFS heavy loads).

**Where:**

- X99 AI worker (dual Xeon, Arc GPUs).
- CW-NAS-AMD (AI controller) if it runs GPU workloads.
- Docker worker (B450) if you observe kernel regressions impacting Docker or
  ZFS behavior.

**Notes:**

- Document which kernel you pin and why (e.g. in an ADR or in the host
  page).
- Revisit after major Proxmox or Debian upgrades.

### 2.4. PBS Post Install (For Backup Nodes)

**Goal:**  
Standardize repository config and post-install for Proxmox Backup Server
(PBS) in the same way as PVE Post Install does for Proxmox VE.

**When:**

- Once a dedicated PBS host (or VM) is introduced into the homelab.

**Where:**

- On the PBS instance only.

**Notes:**

- Keep PBS on a stable kernel and stable repos; treat it as core
  infrastructure.

## 3. Scripts for Later Phases (Services & Monitoring)

These scripts are not required in the initial configuration, but are useful
when rolling out services.

### 3.1. LXC Application Installers

The helper-scripts catalog includes many installers for popular applications
inside LXC containers, such as:

- Databases
- Web services
- Media services
- Home automation tools
- Developer utilities

**Strategy:**

- Prefer using these scripts for quickly spinning up “standard” services,
  but document which script was used (name, date, options).
- For critical infrastructure (e.g. core Postgres, Wiki, Vaultwarden) you
  may still prefer a “manual” deploy in a VM or hand-crafted LXC.

### 3.2. LXC Tagging / QoL Tools

Some scripts add meta-information or tags to LXC containers for clearer
overviews in the Proxmox UI.

**Use when:**

- The number of LXC containers grows.
- You want IP addresses and roles visible at a glance.

### 3.3. Monitoring: Netdata and Others

Helper scripts can set up tools like Netdata or similar monitoring stacks.

**Where:**

- Qotom (to see overall cluster health).
- X99 AI worker and Docker worker for performance monitoring.
- Possibly dedicated monitoring nodes/containers.

**Notes:**

- Avoid over-complicating monitoring early; start simple and grow as needed.

## 4. Security & Telemetry Considerations

- The helper-scripts are **community-maintained**; some may contact their
  own API endpoints for telemetry/statistics.
- Treat this as you would any external admin script:
  - Read the script or documentation if you are concerned.
  - Consider blocking or filtering outbound access if necessary.
- Always note in your documentation that these scripts are in use and that
  they may adjust system configuration or repositories.

## 5. Summary Matrix

| Phase                   | Node(s)                        | Script              | Purpose                          |
|-------------------------|--------------------------------|---------------------|----------------------------------|
| Initial post-install    | All PVE nodes                  | PVE Post Install    | Fix repos, enable no-sub, etc.  |
| Script management       | Qotom (and optionally others)  | PVEScripts-Local    | Central script dashboard         |
| Kernel stabilization    | X99, AI controller, Docker     | Kernel Pin          | Pin stable kernel                |
| PBS setup               | PBS host/VM                    | PBS Post Install    | Repo & post-install for PBS      |
| Service rollout (LXC)   | Various                        | LXC app installers  | Quick deployment of services     |
| QoL for containers      | Nodes with many LXC            | LXC tag/QoL scripts | Improve overview in PVE UI       |
| Monitoring              | Qotom, X99, Docker worker      | Netdata/monitoring  | Health and performance metrics   |

This strategy keeps the **critical early steps** (post-install, repos,
cluster formation) clean and consistent, while still allowing you to use the
broader helper-scripts ecosystem to speed up later service deployment.
