# Runbook: Setup Proxmox Cluster in Staging Network (10.10.10.x)

## Goal

Set up a Proxmox VE cluster in a **simple staging network** (`10.10.10.0/24`)
so that:

- You have **one cluster** (`homelab-cluster`) with all Proxmox hosts.
- The user/role model is ready (`vincent@pve`, automation users, etc.).
- Adding new nodes later is mostly:
  - Install Proxmox
  - Give IP in `10.10.10.x`
  - `pvecm add 10.10.10.11`

This runbook focuses on **cluster + users + base helper-scripts usage**, not
on VLANs or the final production network layout.

## Prerequisites

- A working **staging network**:

  - IPv4: `10.10.10.0/24`
  - Gateway: `10.10.10.1`
  - Optional: DHCP handing out `10.10.10.x` addresses

- Proxmox VE ISO available, or a netboot entry for Proxmox.
- Hardware:

  - Qotom 1U (cluster seed node)
  - Other Proxmox hosts (HX310-1, HX310-2, B450, X99, pve-8845hs-AMD)

- Console access (local, IPMI, serial, etc.) to each host.
- All hosts support the same Proxmox VE **major version** (e.g. all PVE 8.x).

## High-Level Steps

1. Install Proxmox on the **Qotom** and put it in `10.10.10.x`.
2. Run **PVE Post Install** helper script + updates on Qotom.
3. Create the **cluster** on Qotom (`pvecm create homelab-cluster`).
4. Set up **users, groups, and ACLs** (`vincent@pve`, automation, readonly).
5. Optionally install **PVEScripts-Local** on Qotom for future script usage.
6. For each additional node:
   - Install Proxmox.
   - Run PVE Post Install helper script + updates.
   - Give the node a `10.10.10.x` address.
   - Join the cluster with `pvecm add 10.10.10.11`.
7. Verify cluster health and log in via `vincent@pve`.

## 1. Seed Node (Qotom) – Install & Basic Setup

### 1.1. Install Proxmox VE

1. Boot Qotom from Proxmox VE installer (USB or netboot).
2. Follow the installer:
   - Disk layout: choose your preferred layout (ZFS/ext4).
   - Hostname: `pmx-qotom` (staging).
   - IP address: assign or obtain one in `10.10.10.x` (example: `10.10.10.11`).
   - Gateway: `10.10.10.1`.
3. Complete installation and reboot into Proxmox.

### 1.2. First Login, Helper Scripts & Updates

1. Log in on Qotom as `root` (SSH or console).

2. Sanity check:

   ```bash
   hostname
   ip a
   pveversion
   ```

3. Run the **PVE Post Install** helper script to standardize repositories and
   basic configuration.

   - Go to the Proxmox VE Helper-Scripts website in a browser.
   - Locate the **PVE Post Install** script.
   - Copy the one-liner command (usually something like):

     ```bash
     bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/post-pve-install.sh)"
     ```

   - Paste it into the Qotom shell and follow the prompts (disable
     Enterprise repo if you have no subscription, enable no-subscription
     repo, etc.).

   > If the script indicates that your Proxmox/Debian version is not yet
   > supported, abort and note this in the documentation. You can then fix
   > repositories manually for this host.

4. After running the script, update packages:

   ```bash
   apt update
   apt full-upgrade -y
   ```

5. Confirm:

   ```bash
   pveversion
   cat /etc/apt/sources.list
   ls /etc/apt/sources.list.d/
   ```

   This verifies that repositories are in the expected state.

### 1.3. (Optional) Install PVEScripts-Local on Qotom

If you want a local web UI for helper scripts:

1. On Qotom, open a root shell.
2. Run the helper-script installer for **PVEScripts-Local**:

   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/pve-scripts-local.sh)"
   ```

3. Follow the prompts. This typically creates a Debian LXC and deploys the
   web interface at `http://<LXC-IP>:3000`.

This step is optional but makes it easier to discover and run additional
helper scripts later.

## 2. Create the Cluster on Qotom

### 2.1. Cluster Creation

On Qotom:

```bash
# Check cluster status (should show no cluster yet)
pvecm status

# Create new cluster
pvecm create homelab-cluster
```

Possible issues:

- If you see an error like “Cluster already defined”, you are likely using a
  reused or misconfigured install. In staging, it is often fastest to
  reinstall Proxmox cleanly on that node.

After successful creation:

```bash
pvecm status
```

It should show:

- One node (pmx-qotom).
- Status: Quorate.
- A single ring.

## 3. Proxmox Users, Groups & Roles (Seed Node)

Perform these steps on Qotom after cluster creation.

### 3.1. Create Admin Group & User

```bash
# Admin group
pveum group add homelab-admins --comment "Full admins for homelab"

# Admin user
pveum user add vincent@pve --comment "Vincent homelab admin"

# Add user to admin group
pveum groupmod homelab-admins -add_user vincent@pve

# Assign full rights on datacenter
pveum aclmod / -group homelab-admins -role Administrator
```

You can now log in to the Proxmox web UI as `vincent@pve` (realm `PVE`).
Keep `root@pam` as a break-glass account.

### 3.2. Create Automation Group & User

For Warp.dev or other automation:

```bash
# Automation group
pveum group add automation --comment "Automation & API clients"

# Automation user
pveum user add warpdev@pve --comment "Warp.dev automation user"

# Add user to automation group
pveum groupmod automation -add_user warpdev@pve

# Give VM admin rights
pveum aclmod / -group automation -role PVEVMAdmin
```

Then, in the web UI:

- Go to Datacenter → Permissions → API Tokens → Add.
- Create a token for `warpdev@pve` (e.g. `warp-cli`), with privilege
  separation enabled.

Scope can be tightened later (for example only to specific nodes or paths).

### 3.3. Optional: Read-Only User

```bash
pveum group add readonly --comment "Read-only viewers"

pveum user add viewer@pve --comment "Read-only viewer"
pveum groupmod readonly -add_user viewer@pve

pveum aclmod / -group readonly -role PVEAuditor
```

## 4. Additional Nodes – Install & Join Cluster

Repeat the following pattern per additional Proxmox host.

### 4.1. Install Proxmox on Each Node

For each host (HX310-1, HX310-2, B450, X99, pve-8845hs-AMD):

1. Boot from Proxmox installer and install Proxmox VE.
2. During install, assign a hostname and ensure the node lands in
   `10.10.10.x` (via DHCP or static IP).
3. After installation, log in as `root`.

### 4.2. Run PVE Post Install + Updates

On the new node:

1. Run the **PVE Post Install** helper script exactly as done on Qotom.
2. After completion:

   ```bash
   apt update
   apt full-upgrade -y
   ```

3. Ensure `pveversion` roughly matches the seed node’s version (same major
   series, e.g. all 8.x).

### 4.3. Join the Cluster

On the **new node**:

```bash
pvecm add 10.10.10.11
```

Where `10.10.10.11` is the IP of Qotom (seed node).

Common issues:

- **SSH host key mismatch**:
  - If the node previously used the same IP as `10.10.10.11`, clear the
    offending entry in `~/.ssh/known_hosts` on that node and retry.
- **Cluster/corosync errors**:
  - Check on Qotom:

    ```bash
    pvecm status
    journalctl -u corosync --no-pager | tail -n 50
    ```

  - Fix corosync issues before adding more nodes.

### 4.4. Verify Node Presence

On any cluster node:

```bash
pvecm status
```

Verify:

- The new node appears in the node list.
- The cluster is quorate.
- No obvious errors are logged.

In the web UI (logging in as `vincent@pve`), check under `Datacenter` →
`Nodes` that the new node has appeared.

## 5. Common Recovery Scenarios

### 5.1. Node Accidentally Created Its Own Cluster

If you accidentally run `pvecm create` on a node that should join an
existing cluster, you may get:

- Errors when trying to run `pvecm add`.
- Messages indicating the node is already part of a different cluster.

In staging it is usually simplest to:

1. Reinstall Proxmox on that node.
2. Re-run:
   - PVE Post Install helper script.
   - `pvecm add 10.10.10.11`.

### 5.2. Entire Cluster Broken During Experiments

As this is a staging environment, do not hesitate to:

1. Pick a seed node (usually Qotom).
2. Reinstall Proxmox on all nodes.
3. Re-run this runbook from the top.

Once the procedures feel stable, you can copy them into a “production
cluster” runbook.

## 6. Verification & Basic Tests

### 6.1. Admin Login

- Open the Proxmox web UI on Qotom (e.g. `https://10.10.10.11:8006`).
- Log in as:
  - User: `vincent@pve`
  - Realm: `PVE`

Check:

- All nodes appear under `Datacenter`.
- You can navigate into each node and open a shell.

### 6.2. Cluster Status

```bash
pvecm status
```

Expected:

- `Quorate: Yes`
- Nodes: all installed hosts
- No obvious error messages.

### 6.3. API Test for Automation User (Optional)

If you have created a token for `warpdev@pve`, test from any machine in
`10.10.10.x`:

```bash
curl -k \
  -H "Authorization: PVEAPIToken=warpdev@pve!warp-cli=<SECRET>" \
  https://10.10.10.11:8006/api2/json/nodes
```

You should get a JSON list of nodes. If this works, API access is ready.

## 7. Next Steps

After this runbook succeeds, you have:

- A functioning Proxmox cluster in staging.
- A clean user/role model (`vincent@pve`, `warpdev@pve`, etc.).
- All nodes using standardized repositories via PVE Post Install.
- Optionally, PVEScripts-Local installed on Qotom for future helper-script
  usage.

From here you can proceed to:

- Design and deploy the final VLAN-based management, frontend and backend
  networks.
- Create OPNsense VM and network bridges.
- Set up storage (ZFS, NAS access).
- Deploy core services (Postgres, Wiki.js, Vaultwarden, *ARR, AI stack,
  etc.) using a mix of manual methods and helper-scripts where appropriate.
