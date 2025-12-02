# pve-deploy Tool Integration Summary

**Date:** 2025-11-30
**Integration:** Merged from `proxmox-helper-scripts-analysis` repository

## What Was Integrated

This document summarizes the integration of the `pve-deploy` CLI tool and related automation into the main Proxmox-Based-Homelab repository.

### Files Added

#### Automation Tools
- **`automation/pve-deploy`** (executable)
  - Non-interactive CLI wrapper for Proxmox Community Scripts
  - Bypasses whiptail/TUI prompts using configuration files
  - Supports dry-run mode and verbose output
  - Lists all 300+ available services

- **`automation/deploy-hx310-db-phase3.sh`** (executable)
  - Complete automation for Phase 3 core services deployment
  - Deploys: PostgreSQL, Vaultwarden, Gitea, Wiki.js
  - Includes prerequisite checks and SSH connectivity testing
  - Provides detailed deployment plan and post-install instructions

#### Configuration Files (`automation/configs/`)
- **`hx310-db-postgresql.conf`** - PostgreSQL (CT 100, IP: 192.168.10.20)
- **`hx310-db-vaultwarden.conf`** - Vaultwarden (CT 101, IP: 192.168.10.21)
- **`hx310-db-gitea.conf`** - Gitea (CT 102, IP: 192.168.10.22)
- **`hx310-db-wikijs.conf`** - Wiki.js (CT 103, IP: 192.168.10.23)

All configurations:
- Use staging network addressing (192.168.10.x/16)
- Include inline documentation and post-install notes
- Specify proper resource allocation per service
- Aligned with HX310-DB (breintrein) deployment plan

#### Documentation (`docs/`)
- **`COMMUNITY_SCRIPTS_GUIDE.md`** (509 lines)
  - Comprehensive guide to using community scripts programmatically
  - Architecture explanation (two-stage execution model)
  - Complete variable reference
  - Service-specific deployment notes
  - Advanced topics (ZFS, VLANs, batch deployment)
  - Troubleshooting section

- **`QUICK_REFERENCE.md`** (314 lines)
  - Quick command reference for common operations
  - Service deployment examples
  - Post-install task checklists
  - Container management commands
  - Resource recommendations table
  - Useful one-liners

- **`PVE-DEPLOY-INTEGRATION.md`** (this file)
  - Integration summary
  - Usage guide
  - Migration notes

#### Updates to Existing Files
- **`WARP.md`** - Added pve-deploy section with usage examples
- **`automation/README.md`** - Documented new tools (to be completed)

## How It Works

### pve-deploy Architecture

**Purpose:** Enable non-interactive, programmatic deployment of Proxmox community scripts

**Two-Stage Community Scripts Process:**
1. **Container Creation** (runs on Proxmox host)
   - Sources `community-scripts/misc/build.func`
   - Reads `var_*` environment variables
   - Creates LXC container via `pct create`
   - Transfers install script to container

2. **Service Installation** (runs inside container)
   - Updates system packages
   - Installs dependencies
   - Configures service
   - Creates systemd unit
   - Starts service

**pve-deploy Integration:**
- Exports `var_*` variables from configuration file
- Executes community script with pre-set environment
- Bypasses whiptail TUI prompts
- Provides dry-run capability
- Supports SSH-based remote execution

### Variable System

All customization uses `var_` prefixed environment variables:

**Container Configuration:**
- `var_ctid` - Container ID (auto if empty)
- `var_hostname` - Container hostname
- `var_cpu` - CPU cores
- `var_ram` - RAM in MB
- `var_disk` - Disk size in GB
- `var_storage` - Storage location
- `var_unprivileged` - 1=unprivileged, 0=privileged

**Network Configuration:**
- `var_brg` - Bridge interface (default: vmbr0)
- `var_net` - `dhcp` or `ip=x.x.x.x/xx,gw=x.x.x.x`
- `var_vlan` - VLAN tag (optional)
- `var_gateway` - Gateway IP

**Other Options:**
- `var_ssh` - Enable SSH (yes/no)
- `var_pw` - Root password (auto-generated if empty)
- `var_verbose` - Verbose output (yes/no)
- `var_tags` - Semicolon-separated tags

See `docs/COMMUNITY_SCRIPTS_GUIDE.md` for complete reference.

## Usage Examples

### Basic Deployment

```bash
# List available services
cd /home/emesix/Proxmox-Based-Homelab
./automation/pve-deploy --list

# Deploy PostgreSQL
./automation/pve-deploy -c automation/configs/hx310-db-postgresql.conf postgresql

# Dry run for Vaultwarden
./automation/pve-deploy -c automation/configs/hx310-db-vaultwarden.conf --dry-run vaultwarden
```

### Phase 3 HX310-DB Deployment

```bash
# Preview full Phase 3 deployment
./automation/deploy-hx310-db-phase3.sh --dry-run

# Execute Phase 3 deployment
./automation/deploy-hx310-db-phase3.sh

# Execute without confirmation prompts
./automation/deploy-hx310-db-phase3.sh --skip-confirmation
```

### Creating Custom Configurations

```bash
# Copy a template
cp automation/configs/hx310-db-postgresql.conf automation/configs/my-service.conf

# Edit configuration
nano automation/configs/my-service.conf

# Modify key variables:
# - var_ctid (container ID)
# - var_hostname (hostname)
# - var_net (IP address)
# - var_cpu, var_ram, var_disk (resources)

# Test with dry run
./automation/pve-deploy -c automation/configs/my-service.conf --dry-run myservice

# Deploy
./automation/pve-deploy -c automation/configs/my-service.conf myservice
```

## Integration with Existing Workflow

### Relationship to Community Scripts

**DO:** Use pve-deploy as a wrapper around community scripts
- Maintains compatibility with upstream updates
- Preserves script best practices
- No modification to community scripts needed

**DON'T:** Modify community scripts directly
- Updates will overwrite changes
- Use configuration files to customize instead

### Relationship to Existing Automation

**Complements existing automation:**
- Works alongside `deploy-ssh-keys.sh`
- Integrates with `setup-proxmox-cluster.sh`
- Can be called from higher-level orchestration scripts

**Example integration:**
```bash
#!/bin/bash
# Full Phase 3 deployment with cluster setup

# 1. Deploy SSH keys
./automation/deploy-ssh-keys.sh

# 2. Setup cluster
./automation/setup-proxmox-cluster.sh

# 3. Deploy services
./automation/deploy-hx310-db-phase3.sh --skip-confirmation
```

## Troubleshooting

### Common Issues

**"community-scripts directory not found"**
```bash
cd /home/emesix/Proxmox-Based-Homelab
git clone https://github.com/community-scripts/ProxmoxVE.git community-scripts
```

**"Cannot connect via SSH"**
```bash
# Verify connectivity
ping 192.168.10.12

# Deploy SSH keys
./automation/deploy-ssh-keys.sh

# Test SSH
ssh root@192.168.10.12 "echo OK"
```

**"Script prompts for input despite using config"**
- Some scripts have built-in prompts (e.g., PostgreSQL version)
- Workaround: Pipe input to script
- Example: `echo "16" | ./automation/pve-deploy ...`

**"Storage not found"**
```bash
# Check available storage on Proxmox host
ssh root@192.168.10.12 "pvesm status"

# Update config with correct storage name
nano automation/configs/your-service.conf
# Change: export var_storage="local-lvm"  # or correct name
```

### Debug Mode

Enable verbose output for troubleshooting:
```bash
# In configuration file
export var_verbose="yes"

# Via command line
./automation/pve-deploy -c config.conf -v service
```

## Future Enhancements

### Planned Improvements
1. **Complete deploy-hx310-db-phase3.sh implementation**
   - Currently has placeholder functions for Vaultwarden, Gitea, Wiki.js
   - Need to implement full SSH-based remote deployment

2. **Post-deployment automation**
   - Automated database creation
   - Service integration testing
   - Credential storage in Vaultwarden

3. **Configuration templates**
   - Add configs for all planned services
   - Create per-host deployment bundles

4. **Backup integration**
   - Automated backup script generation
   - ZFS snapshot scheduling
   - NAS sync automation

5. **Monitoring hooks**
   - Health check integration
   - Resource monitoring setup
   - Alert configuration

### Integration with AI Controller

Future AI controller (**hoofdstuk**) can use pve-deploy for:
- Automated service deployment based on workload
- Self-healing container recreation
- Dynamic resource allocation
- Backup and recovery automation

## Related Documentation

- **Comprehensive Guide:** `docs/COMMUNITY_SCRIPTS_GUIDE.md`
- **Quick Reference:** `docs/QUICK_REFERENCE.md`
- **Phase 3 Plan:** Warp Drive Notebook - HX310-DB Core Services Deployment
- **Service Inventory:** `docs/plan/40-service-inventory-and-placement.md`
- **Roadmap:** `docs/plan/10-roadmap.md`

## Credits

**Original pve-deploy development:** proxmox-helper-scripts-analysis repository
**Community Scripts:** https://github.com/community-scripts/ProxmoxVE
**Integration Date:** 2025-11-30
**Homelab Project:** Proxmox-Based-Homelab

---

**Next Steps:**
1. Test pve-deploy with PostgreSQL deployment on HX310-DB
2. Complete Phase 3 automation script implementation
3. Document actual deployment results
4. Update service inventory with deployed containers
5. Create runbook-003-hx310-db-services.md
