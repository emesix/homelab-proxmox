# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is Vincent's Proxmox-based homelab infrastructure repository - the **source of truth** for hardware, network topology, service placement, and operational runbooks. The repo documents a multi-node Proxmox cluster with specialized hosts for databases, AI workloads, media automation, and infrastructure services.

### Key Concepts

- **Staging Network**: Initial deployment uses flat `10.10.0.0/16` network with IPs pre-assigned to match future VLAN structure
- **VLAN Transition**: IPs already aligned to future /24 blocks (e.g., `10.10.200.x` = future MGMT VLAN 200)
- **Dutch "Street Names"**: Each host and service has a playful Dutch nickname (bijnaam) for easier documentation and AI interaction
  - Example: `pmx-hx310-db` = **breintrein** (brain-train), `pmx-qotom` = **vuurbuur** (fire-neighbor)
- **Community Scripts**: The `community-scripts/` directory contains Proxmox VE Helper Scripts (ProxmoxVE community project) for LXC/service deployment

## Common Commands

### Cluster Management

```bash
# Collect hardware info from a Proxmox node
./automation/collect-hardware-info.sh <node_ip> <output_dir>

# Deploy SSH keys to all nodes (staging password: NikonD90)
./automation/deploy-ssh-keys.sh

# Setup Proxmox cluster with pve-qotom01 as master
./automation/setup-proxmox-cluster.sh

# Join all nodes to cluster
./automation/join-all-nodes.sh

# Join single node to cluster
./automation/join-node-to-cluster.sh <node_ip>
```

### SSH Access

```bash
# Connect to nodes (passwordless after SSH key deployment)
ssh root@192.168.10.11  # pve-qotom01 (vuurbuur)
ssh root@192.168.10.12  # pve-hx310-db (breintrein)
ssh root@192.168.10.13  # pve-hx310-arr (downloadboef)
ssh root@192.168.10.14  # pve-5700g (klusbus)
ssh root@192.168.10.15  # pve-8845hs (hoofdstuk)
ssh root@192.168.10.16  # pve-x2686-x2 (denkdoos)
```

### Proxmox CLI Operations

```bash
# Check cluster status
ssh root@<node> "pvecm status"

# List nodes in cluster
ssh root@<node> "pvecm nodes"

# List VMs and containers
ssh root@<node> "qm list"
ssh root@<node> "pct list"

# Check storage
ssh root@<node> "pvesm status"

# Get node version info
ssh root@<node> "pveversion -v"
```

### Deploying Services with Community Scripts

```bash
# Deploy core services on HX310-DB (breintrein)
ssh root@192.168.10.12 'bash -s' < community-scripts/ct/postgresql.sh
ssh root@192.168.10.12 'bash -s' < community-scripts/ct/vaultwarden.sh
ssh root@192.168.10.12 'bash -s' < community-scripts/ct/gitea.sh
ssh root@192.168.10.12 'bash -s' < community-scripts/ct/wikijs.sh

# Deploy light ARR services on HX310-ARR (downloadboef)
ssh root@192.168.10.13 'bash -s' < community-scripts/ct/prowlarr.sh
ssh root@192.168.10.13 'bash -s' < community-scripts/ct/lidarr.sh
ssh root@192.168.10.13 'bash -s' < community-scripts/ct/readarr.sh
ssh root@192.168.10.13 'bash -s' < community-scripts/ct/sabnzbd.sh

# Deploy heavy ARR services on 5700G (klusbus)
ssh root@192.168.10.14 'bash -s' < community-scripts/ct/sonarr.sh
ssh root@192.168.10.14 'bash -s' < community-scripts/ct/radarr.sh
ssh root@192.168.10.14 'bash -s' < community-scripts/ct/bazarr.sh
```

## Architecture & Code Structure

### Directory Layout

```
.
├── automation/         # Cluster setup and management scripts
│   ├── collect-hardware-info.sh
│   ├── deploy-ssh-keys.sh
│   ├── setup-proxmox-cluster.sh
│   └── join-*.sh
├── community-scripts/  # Proxmox VE Helper Scripts (gitignored, cloned separately)
├── docs/
│   ├── plan/          # Future-state designs and phased rollout plans
│   ├── runbooks/      # Operational procedures
│   ├── decisions/     # ADR-style decision records
│   ├── hw/            # Hardware documentation
│   ├── infra/         # Infrastructure documentation
│   └── incidents/     # Incident postmortems (placeholder)
├── hosts/             # Per-host overview files
├── proxmox/           # Proxmox cluster notes and VM/LXC inventories
└── docker/stacks/     # Docker compose stacks for services
```

### Critical Architecture Patterns

**Six-Node Proxmox Cluster**:
1. **pve-qotom** (vuurbuur): LAN management, OPNsense firewall VM, netboot, WiFi mgmt, CUPS
2. **pve-hx310-db** (breintrein): PostgreSQL, Vaultwarden, Wiki.js, Gitea - "tier 0" core services
3. **pve-hx310-arr** (downloadboef): Light *ARR services (Prowlarr, Lidarr, Readarr), NZB download clients
4. **pve-5700g** (klusbus): Heavy *ARR services (Sonarr, Radarr), heavy Docker workloads, CI/automation
5. **pve-8845hs** (hoofdstuk): AI controller/orchestrator, Open WebUI, vector DB, API gateway
6. **pve-x99-ai** (denkdoos): AI worker with dual Intel Arc A770 GPUs (intermittent power-on)

**Storage Strategy**:
- Local ZFS for performance-critical workloads
- Unraid NAS (`nas-unraid` / **schuifkast**) for backups and media storage
- Future: Proxmox Backup Server integration

**Network Phases**:
- Phase 1 (Current): Staging flat `10.10.0.0/16` network
- Phase 4 (Planned): VLAN segmentation without IP changes (VLANs 20, 30, 40, 90, 100-130, 200)

**Service Dependencies**:
- PostgreSQL is "tier 0" - other services (Vaultwarden, Wiki.js) depend on it
- Wiki.js syncs with Git (GitHub SSoT, with local Gitea mirror)
- AI controller (**hoofdstuk**) routes to Bronze (local), Silver (GPU worker), Gold (external APIs)

### Script Conventions

From `automation/README.md`:
- Scripts must be maintainable by "future you"
- Destructive actions require:
  - Clear documentation of what they do
  - `--dry-run` support or similar
  - Confirmation prompts or `--force` flag

### Community Scripts Usage

**Always use Proxmox VE Helper Scripts from the community-scripts repository** for deploying LXC containers and services. DO NOT create custom containers from scratch.

- Local copy: `/home/emesix/Proxmox-Based-Homelab/community-scripts/`
- Upstream: https://github.com/community-scripts/ProxmoxVE
- Contains pre-built scripts for common services (PostgreSQL, Gitea, Vaultwarden, Wiki.js, *ARR suite, etc.)
- Scripts are located in `community-scripts/ct/` directory
- Each script handles LXC creation, OS installation, and service configuration
- Scripts follow best practices and are community-maintained

**Example usage:**
```bash
# Run a helper script to deploy PostgreSQL LXC
bash community-scripts/ct/postgresql.sh

# Deploy Prowlarr
bash community-scripts/ct/prowlarr.sh
```

### Hardware Collection

The `collect-hardware-info.sh` script generates comprehensive markdown reports including:
- CPU, memory, storage, network details
- ZFS pools, LVM volumes, SMART status
- Proxmox storage and network configuration
- PCI/USB devices

Output format: `<hostname>-hardware-report.md`

### Media Automation Preferences

**Download Method: Newsgroups (Usenet) - PRIMARY**
- Preferred over torrents for speed and security
- Active accounts:
  - **Drunkenslug** - NZB indexer
  - **NZB Finder** - NZB indexer
- Download client: SABnzbd or NZBGet (choose based on performance)
- Indexer manager: Prowlarr (deployed on HX310-ARR)

**ARR Suite Distribution:**
- **HX310-ARR (downloadboef)** - Light services:
  - Prowlarr (indexer management)
  - Lidarr (music)
  - Readarr (books)
  - NZB download client (SABnzbd/NZBGet)
- **5700G (klusbus)** - Heavy services:
  - Sonarr (TV shows - high processing load)
  - Radarr (movies - high processing load)
  - Bazarr (subtitles - optional)

This split balances load: HX310-ARR handles lightweight indexing and smaller media types, while 5700G's more powerful CPU handles the intensive TV/movie processing.

### pve-deploy CLI Tool

**Non-Interactive Script Deployment**: The `automation/pve-deploy` tool enables programmatic deployment of community scripts without TUI interactions.

**Basic Usage:**
```bash
# List all available services (300+ options)
./automation/pve-deploy --list

# Deploy with configuration file
./automation/pve-deploy -c automation/configs/hx310-db-postgresql.conf postgresql

# Dry run to preview
./automation/pve-deploy -c automation/configs/hx310-db-vaultwarden.conf --dry-run vaultwarden
```

**Phase 3 HX310-DB Deployment:**
```bash
# Automated deployment of all Phase 3 core services
./automation/deploy-hx310-db-phase3.sh --dry-run  # Preview
./automation/deploy-hx310-db-phase3.sh            # Execute
```

**Configuration Files:**
- `automation/configs/hx310-db-postgresql.conf` - PostgreSQL (CT 100)
- `automation/configs/hx310-db-vaultwarden.conf` - Vaultwarden (CT 101)
- `automation/configs/hx310-db-gitea.conf` - Gitea (CT 102)
- `automation/configs/hx310-db-wikijs.conf` - Wiki.js (CT 103)

All configs use staging network IPs (192.168.10.x) that align with future VLAN structure.

**Documentation:**
- `docs/COMMUNITY_SCRIPTS_GUIDE.md` - Comprehensive guide (500+ lines)
- `docs/QUICK_REFERENCE.md` - Quick command reference
- Configuration files include inline deployment notes

## Key Files to Know

### Planning Documents
- `docs/plan/10-roadmap.md` - Seven-phase rollout plan from staging to production
- `docs/plan/40-service-inventory-and-placement.md` - Complete service mapping with Dutch nicknames
- `docs/plan/50-network-layout-and-security-levels.md` - VLAN design and security zones
- `docs/plan/55-staging-network-and-vlan-transition.md` - IP addressing strategy

### Operational Runbooks
- `docs/runbooks/setup-proxmox-cluster-staging.md` - Complete cluster setup procedure
- `docs/runbooks/runbook-001-proxmox-host-installation.md` - Host installation steps
- `docs/runbooks/runbook-002-opnsense-staging-to-production.md` - OPNsense migration

### Host Documentation
- `hosts/<hostname>.md` - Per-host specs, role, and planned services
- `proxmox/cluster-layout.md` - Cluster strategy and storage overview

### Automation Scripts
- `automation/deploy-ssh-keys.sh` - SSH key deployment (uses sshpass with staging password)
- `automation/setup-proxmox-cluster.sh` - Cluster initialization with hostname fixes
- `automation/collect-hardware-info.sh` - Remote hardware inventory collection

## Network Addressing (Staging Phase)

Current staging IPs (will become VLAN-segmented later):
- `10.10.200.11` - pve-qotom (future MGMT VLAN 200)
- `10.10.200.12` - pve-hx310-db (future MGMT VLAN 200)
- `10.10.200.13` - pve-hx310-arr (future MGMT VLAN 200)
- `10.10.200.14` - pve-5700g (future MGMT VLAN 200)
- `10.10.200.15` - pve-8845hs (future MGMT VLAN 200)
- `10.10.200.16` - pve-x2686-x2 (future MGMT VLAN 200)

Services will be assigned IPs in VLAN 100-130 range for backend services.

## Working with This Repository

### Before Making Changes

1. **Check the roadmap**: Review `docs/plan/10-roadmap.md` to understand current phase
2. **Review existing runbooks**: Check if operational procedure already exists
3. **Understand Dutch naming**: Familiarize with service nicknames in `docs/plan/40-service-inventory-and-placement.md`
4. **Respect the SSoT**: GitHub is source of truth, Wiki.js is consumer (Phase 3+)

### When Adding Scripts

- Place in `automation/` directory
- Follow script conventions (documentation, dry-run support, confirmations)
- Update relevant runbook in `docs/runbooks/`
- Test against staging network before production use

### When Documenting Services

- Create host file in `hosts/` if new hardware added
- Update service inventory in `docs/plan/40-service-inventory-and-placement.md`
- Include both technical hostname and Dutch bijnaam
- Document in format: `<technical-name> (<bijnaam>)` - e.g., "pve-hx310-db (breintrein)"

### When Working with Proxmox

- Always use `--no-pager` with git commands
- Check cluster status before major operations
- Hardware reports go to `docs/hw/` or similar subdirectory
- Respect node specialization (don't schedule GPU workloads on non-GPU nodes)

### Security Notes

- Staging password `NikonD90` is temporary and documented for development
- Production will use Vaultwarden for credential management
- `automation/deploy-ssh-keys.sh` contains staging password in plaintext (acceptable for staging only)
- Future: migrate all secrets to Vaultwarden after Phase 3 deployment

## AI Controller Integration Notes

The AI controller node (**hoofdstuk** / pve-8845hs) will integrate with this repository:
- Pull context from Wiki.js synced with these docs
- Access runbooks for automated operations
- Use MCP tools for infrastructure automation
- Route tasks between Bronze (local), Silver (GPU worker), and Gold (external API) tiers

When adding automation for AI integration:
- Document API endpoints and authentication
- Specify which operations require human confirmation
- Note resource requirements and scheduling constraints
- Consider power management for intermittent GPU worker node

## Common Patterns

### Running Remote Commands on All Nodes

```bash
for ip in 192.168.10.{11..16}; do
  echo "=== Node $ip ==="
  ssh root@$ip "your-command-here"
done
```

### Checking Cluster Health

```bash
ssh root@192.168.10.11 "pvecm status && pvecm nodes && pveversion"
```

### Collecting Info From All Nodes

```bash
mkdir -p reports
for ip in 192.168.10.{11..16}; do
  ./automation/collect-hardware-info.sh $ip reports/
done
```

## Notes for Future Warp Instances

- **ALWAYS use community scripts**: Never create LXC containers manually - use scripts from `community-scripts/ct/` directory
- **Community scripts directory**: Local copy at `/home/emesix/Proxmox-Based-Homelab/community-scripts/` (gitignored)
- **Staging vs Production**: Currently in staging phase (flat network) - check roadmap for VLAN transition status
- **Dutch naming system**: Don't be confused by bijnamen - they're intentional for easier documentation
- **GitHub is SSoT**: Even after Wiki.js deployment, GitHub remains authoritative for infrastructure code
- **Newsgroup preference**: Use Usenet/NZB (Drunkenslug, NZB Finder) not torrents for media downloads
- **ARR split**: Light services on HX310-ARR, heavy services (Sonarr/Radarr) on 5700G
