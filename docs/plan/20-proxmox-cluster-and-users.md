# Proxmox Cluster & User Implementation Plan

## Scope & Goals

This document describes how the Proxmox cluster and user/role model are set up
in a **simple staging network**:

- Management / staging network: `10.10.10.0/24` with DHCP.
- All Proxmox hosts are connected to this network during initial setup.
- After the first Proxmox node is configured as the **seed node**, all other
  nodes should be easy to install and join to the same cluster.

Network details such as VLANs, final IP schema and OPNsense rules are handled
in separate documents. Here we focus only on:

- Cluster structure (nodes, cluster name).
- User/role model (admin user, automation users).
- Using **community-scripts** (Proxmox VE Helper-Scripts) to standardize
  repository and base configuration where helpful.

## 1. Staging Environment & Naming

### 1.1. Staging Network

- IPv4: `10.10.10.0/24`
- Gateway: `10.10.10.1`
- DNS: typically the same as the gateway, or a public resolver.
- DHCP: enabled to hand out `10.10.10.x` addresses to all Proxmox hosts.

This is a **temporary / staging** environment for:

- Clean installation of all Proxmox hosts.
- Initial cluster formation.
- Initial user/role setup and basic verification.

Later the hosts can be moved to the final management network (with VLANs and
static addresses).

### 1.2. Hostnames & IPs (Staging)

Proposed staging hostnames and addresses:

| Host          | Role            | Hostname (staging) | IP (10.10.10.0/24) |
|---------------|-----------------|--------------------|---------------------|
| Qotom 1U      | Cluster seed    | `pmx-qotom`        | 10.10.10.11         |
| HX310-1       | DB / core       | `pmx-hx310-db`     | 10.10.10.21         |
| HX310-2       | *ARR / media    | `pmx-hx310-arr`    | 10.10.10.22         |
| B450 5700G    | Docker worker   | `pmx-docker`       | 10.10.10.31         |
| X99 dual      | AI worker       | `pmx-ai-worker`    | 10.10.10.41         |
| CW-NAS-AMD    | AI controller   | `pmx-ai-ctl`       | 10.10.10.51         |

In staging you can start with pure DHCP and later convert these to DHCP
reservations or static IPs once the addresses are stable.

## 2. Cluster Concept: Seed Node + Join

### 2.1. Cluster Name

- Cluster name: `homelab-cluster`

This name is used on the **first node** (the seed node) when the cluster is
created with `pvecm create`.

### 2.2. Seed Node (Qotom)

The Qotom host acts as the **cluster seed node**:

1. Install Proxmox VE on Qotom.
2. Ensure it gets an address in `10.10.10.x`.
3. On Qotom, create the cluster:

   ```bash
   pvecm create homelab-cluster
   ```

After this, `pmx-qotom` is the initial member of the cluster and serves as
the point where other nodes will join.

## 3. User Model: Away From root@pam

The goal is to avoid daily management via `root@pam`, and instead:

- Use `root@pam` for:
  - initial installation,
  - break-glass / recovery.
- Use one or more **admin users** in the PVE realm for daily operations.
- Use dedicated **automation users** for tasks like Warp.dev, CI jobs, etc.
- Optionally use read-only users for dashboards / monitoring.

### 3.1. Realms

- `PAM` realm:
  - Only `root@pam` and possibly OS-level admins.
- `PVE` realm:
  - Internal Proxmox users (`vincent@pve`, `warpdev@pve`, etc.).

### 3.2. Groups & Roles

Define three core groups:

- `homelab-admins`  
  Full administrator rights for the entire datacenter.
- `automation`  
  Users that perform scripted or API-based tasks.
- `readonly`  
  Read-only access for monitoring/inspection.

Proxmox built-in roles of interest:

- `Administrator` – full control over the assigned path.
- `PVEAdmin` – powerful admin but without some global tasks.
- `PVEVMAdmin` – mainly VM/LXC related rights.
- `PVEAuditor` – read-only.

### 3.3. Primary Admin User

A dedicated admin user, e.g. `vincent@pve`, is used for everyday management.

On the seed node:

```bash
# Create admin group
pveum group add homelab-admins --comment "Full admins for homelab"

# Create admin user in PVE realm
pveum user add vincent@pve --comment "Vincent homelab admin"

# Add user to admin group
pveum groupmod homelab-admins -add_user vincent@pve

# Give admin group full rights on the datacenter
pveum aclmod / -group homelab-admins -role Administrator
```

From this point, login via the web UI as:

- User: `vincent@pve`
- Realm: `PVE`

`root@pam` is kept as a break-glass account.

### 3.4. Automation User

For Warp.dev or similar automation:

```bash
# Group for automation
pveum group add automation --comment "Automation & API clients"

# Automation user
pveum user add warpdev@pve --comment "Warp.dev automation user"

# Add user to automation group
pveum groupmod automation -add_user warpdev@pve

# Give automation group VM admin rights
pveum aclmod / -group automation -role PVEVMAdmin
```

Then create an API token for `warpdev@pve` via the Proxmox web UI:

- Datacenter → Permissions → API Tokens → Add
  - User: `warpdev@pve`
  - Token Name: e.g. `warp-cli`
  - Enable privilege separation.

Later, ACL scope for automation can be tightened to only the paths that
really need management (for instance `/nodes/pmx-ai-worker` or `/vms`).

### 3.5. Read-Only User (Optional)

For monitoring or dashboards:

```bash
pveum group add readonly --comment "Read-only viewers"

pveum user add viewer@pve --comment "Read-only viewer"
pveum groupmod readonly -add_user viewer@pve

pveum aclmod / -group readonly -role PVEAuditor
```

## 4. Helper Scripts Strategy (High-Level)

The Proxmox VE Helper-Scripts project provides community-maintained scripts
to manage repositories, set up LXC containers and more. They are **not
official Proxmox** scripts and should be treated as a convenience layer,
especially in homelab scenarios.

For the cluster and user setup phase, the following scripts are most
relevant (exact usage details in `docs/plan/30-helper-scripts-strategy.md`):

- **PVE Post Install**  
  Standardize repository configuration and basic post-install tasks on each
  Proxmox node.
- **PVEScripts-Local (PVE Scripts Local)**  
  Optional web UI-based script manager that exposes the helper scripts in a
  local web interface.
- **Kernel Pin**  
  Used after the cluster is stable to pin a known-good kernel on specific
  nodes (e.g. GPUs, ZFS heavy nodes).
- **PBS Post Install**  
  Similar to PVE Post Install, but for Proxmox Backup Server nodes.

These scripts are integrated into the staging runbook so that every node is
configured in a consistent way before joining the cluster.

## 5. Adding Nodes: Summary

Once the seed node (`pmx-qotom`) has:

- The cluster created (`pvecm create homelab-cluster`),
- User and group model (`vincent@pve`, `warpdev@pve`, etc.),
- Repositories configured via helper scripts,

the process for each additional node is:

1. Install Proxmox VE.
2. Connect the node to `10.10.10.x`.
3. Run the **PVE Post Install** helper script and update packages.
4. Join the cluster:

   ```bash
   pvecm add 10.10.10.11
   ```

After joining, each node inherits the cluster-wide user and ACL configuration.

## 6. Checklist

- [ ] Qotom installed with Proxmox VE and in `10.10.10.x`.
- [ ] PVE Post Install script used on Qotom (repos fixed and updated).
- [ ] Cluster created with `pvecm create homelab-cluster`.
- [ ] `vincent@pve` created, added to `homelab-admins`, and `Administrator` on `/`.
- [ ] `warpdev@pve` and other automation/read-only users created (if needed).
- [ ] PVEScripts-Local installed on at least one node (optional but recommended).
- [ ] Additional nodes installed, PVE Post Install used, and joined with `pvecm add`.
