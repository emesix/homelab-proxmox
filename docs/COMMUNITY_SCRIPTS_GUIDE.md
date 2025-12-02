# Proxmox Community Scripts - Comprehensive Guide

This guide explains how to use the Proxmox VE Helper Scripts programmatically without the TUI interface.

## Table of Contents

1. [Overview](#overview)
2. [Script Architecture](#script-architecture)
3. [CLI Wrapper Usage](#cli-wrapper-usage)
4. [Configuration Guide](#configuration-guide)
5. [Service-Specific Notes](#service-specific-notes)
6. [Advanced Topics](#advanced-topics)
7. [Troubleshooting](#troubleshooting)

## Overview

The [Proxmox VE Helper Scripts](https://github.com/community-scripts/ProxmoxVE) provide automated deployment of 300+ services as LXC containers. While designed for interactive use, this guide shows how to automate them.

### Why This Matters

- **Automation**: Deploy multiple services programmatically
- **Infrastructure as Code**: Version control your homelab deployments
- **Reproducibility**: Consistent deployments across nodes
- **CI/CD Integration**: Incorporate into automation pipelines

## Script Architecture

### Two-Stage Execution

#### Stage 1: Container Creation (`ct/*.sh`)
Runs on the Proxmox host:
1. Sources core functions from `misc/build.func`
2. Sets default variables (CPU, RAM, disk)
3. Either prompts user (interactive) or uses environment variables (non-interactive)
4. Creates LXC container via `pct create`
5. Pushes install script to container
6. Executes install script inside container

#### Stage 2: Service Installation (`install/*-install.sh`)
Runs inside the new container:
1. Updates package lists
2. Installs dependencies
3. Downloads/compiles application
4. Creates system user/group
5. Sets up configuration files
6. Creates systemd service
7. Enables and starts service

### Core Functions

Located in `misc/build.func`:

- `variables()`: Initialize default variables
- `build_container()`: Create LXC via Proxmox API
- `update_script()`: Handle updates to existing containers
- `base_settings()`: Apply default settings
- `advanced_settings()`: Interactive TUI configuration

### Environment Variable System

All customization uses `var_` prefixed environment variables:

```bash
export var_ctid="100"
export var_hostname="myservice"
export var_cpu="2"
export var_ram="4096"
```

These override default values defined in the script.

## CLI Wrapper Usage

### Installation

```bash
# Clone community scripts
git clone https://github.com/community-scripts/ProxmoxVE.git community-scripts

# Make wrapper executable
chmod +x pve-deploy
```

### Basic Commands

```bash
# List all available services
./pve-deploy --list

# Deploy a service
./pve-deploy -c configs/postgresql.conf postgresql

# Dry run (preview without executing)
./pve-deploy -c configs/vaultwarden.conf --dry-run vaultwarden

# Verbose output
./pve-deploy -c configs/gitea.conf -v gitea
```

## Configuration Guide

### Configuration File Format

Configuration files are bash scripts that export environment variables:

```bash
#!/bin/bash
# Service Configuration

# Container Identity
export var_ctid="100"                    # Container ID
export var_hostname="service-name"       # Hostname

# Resources
export var_cpu="2"                       # CPU cores
export var_ram="4096"                    # RAM in MB
export var_disk="50"                     # Disk size in GB

# Storage
export var_storage="local-lvm"           # Storage location

# Container Type
export var_unprivileged="1"              # 1=unprivileged, 0=privileged

# OS
export var_os="debian"                   # debian, ubuntu, alpine
export var_version="12"                  # OS version

# Network
export var_brg="vmbr0"                   # Bridge
export var_net="dhcp"                    # dhcp or ip=x.x.x.x/xx,gw=x.x.x.x
export var_vlan=""                       # VLAN tag (optional)

# SSH
export var_ssh="yes"                     # Enable SSH
export var_ssh_authorized_key=""         # SSH public key (optional)

# Security
export var_pw=""                         # Root password (auto-generated if empty)

# Other
export var_verbose="no"                  # Verbose output
export var_tags="tag1;tag2"              # Tags for organization
```

### Variable Reference

#### Container Configuration

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `var_ctid` | Container ID | auto | `100` |
| `var_hostname` | Container hostname | service name | `pg-server` |
| `var_cpu` | CPU cores | 1 | `2` |
| `var_ram` | RAM in MB | 1024 | `4096` |
| `var_disk` | Disk size in GB | 4 | `50` |
| `var_storage` | Storage location | local-lvm | `local-lvm`, `rpool/data` |
| `var_unprivileged` | Container type | 1 | `1` (unprivileged), `0` (privileged) |

#### OS Configuration

| Variable | Description | Values | Example |
|----------|-------------|--------|---------|
| `var_os` | Operating system | `debian`, `ubuntu`, `alpine` | `debian` |
| `var_version` | OS version | depends on OS | `12` (Debian 12) |

#### Network Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `var_brg` | Network bridge | `vmbr0` |
| `var_net` | Network config | `dhcp` or `ip=192.168.1.100/24,gw=192.168.1.1` |
| `var_gateway` | Gateway IP (if static) | `192.168.1.1` |
| `var_vlan` | VLAN tag | `110` |
| `var_mac` | MAC address | `02:00:00:00:00:01` |
| `var_ipv6_method` | IPv6 method | `none`, `dhcp`, `static` |
| `var_ipv6_static` | Static IPv6 | `fd00::1234/64` |

#### Other Options

| Variable | Description | Example |
|----------|-------------|---------|
| `var_ssh` | Enable SSH | `yes` or `no` |
| `var_ssh_authorized_key` | SSH public key | `ssh-rsa AAAA...` |
| `var_pw` | Root password | `SecurePass123!` |
| `var_verbose` | Verbose output | `yes` or `no` |
| `var_tags` | Container tags | `database;production` |
| `var_fuse` | Enable FUSE | `yes` or `no` |
| `var_tun` | Enable TUN | `yes` or `no` |

## Service-Specific Notes

### PostgreSQL

**Script:** `ct/postgresql.sh`

**Special Requirements:**
- Prompts for version selection (15/16/17/18)
- Prompts for Adminer installation

**Workaround for Non-Interactive:**
```bash
# Pipe version selection
echo -e "16\nn" | ./pve-deploy -c configs/postgresql.conf postgresql
# First answer: PostgreSQL version
# Second answer: Skip Adminer (n)
```

**Configuration:**
```bash
export var_cpu="2"
export var_ram="8192"
export var_disk="100"
export var_unprivileged="1"
```

**Post-Install:**
1. Configure remote access in `pg_hba.conf`
2. Set `listen_addresses = '*'` in `postgresql.conf`
3. Create databases and users
4. Tune performance settings

### Vaultwarden

**Script:** `ct/vaultwarden.sh`

**Special Requirements:**
- Compiles from source (Rust) - takes 20-30 minutes
- Requires privileged container (for now)

**Configuration:**
```bash
export var_cpu="4"          # More CPU for compilation
export var_ram="6144"       # More RAM for compilation
export var_disk="20"
export var_unprivileged="0" # Privileged for Docker features
```

**Post-Install:**
1. Access: `https://<IP>:8000`
2. Create admin account
3. Set admin token:
   ```bash
   pct enter <ctid>
   nano /opt/vaultwarden/.env
   # Set ADMIN_TOKEN
   systemctl restart vaultwarden
   ```
4. Disable signups in admin panel
5. Configure database connection (optional)

### Gitea

**Script:** `ct/gitea.sh`

**Special Requirements:**
- None (binary installation)

**Configuration:**
```bash
export var_cpu="1"
export var_ram="2048"
export var_disk="50"
export var_unprivileged="1"
```

**Post-Install:**
1. Access: `http://<IP>:3000`
2. Complete setup wizard:
   - Database: SQLite (default) or PostgreSQL (recommended)
   - Application URL
   - Admin account
3. Configure SSH:
   ```bash
   # SSH available on port 22
   git clone ssh://git@<IP>:22/user/repo.git
   ```

### Wiki.js

**Script:** `ct/wikijs.sh`

**Special Requirements:**
- Requires external database (PostgreSQL/MySQL)
- SQLite NOT supported in v3.x+

**Configuration:**
```bash
export var_cpu="1"
export var_ram="2048"
export var_disk="20"
export var_unprivileged="1"
```

**Post-Install:**
1. Access: `http://<IP>:3000`
2. Complete setup wizard:
   - Database connection (PostgreSQL recommended)
   - Site URL
   - Admin account
3. Configure Git sync:
   - Storage → Git
   - Repository URL
   - Branch
   - Sync schedule

### Docker

**Script:** `ct/docker.sh`

**Special Requirements:**
- Must be privileged container
- Enable nesting and keyctl features

**Configuration:**
```bash
export var_cpu="4"
export var_ram="8192"
export var_disk="100"
export var_unprivileged="0"  # Must be privileged
```

**Post-Install:**
1. Container features automatically enabled
2. Docker and Docker Compose installed
3. User added to docker group

## Advanced Topics

### Using ZFS Datasets

Create ZFS datasets for better storage management:

```bash
# On Proxmox host
zfs create rpool/postgresql
zfs create rpool/vaultwarden
zfs create datastore/gitea

# In configuration
export var_storage="rpool/postgresql"
```

ZFS benefits:
- Snapshots for backups
- Compression
- Checksums
- Quotas

### VLAN Segmentation

Isolate services by VLAN:

```bash
# Database VLAN (110)
export var_vlan="110"
export var_net="ip=10.10.110.20/24,gw=10.10.110.1"

# Backend Services VLAN (100)
export var_vlan="100"
export var_net="ip=10.10.100.20/24,gw=10.10.100.1"
```

### Batch Deployment

Deploy multiple services at once:

```bash
#!/bin/bash
# deploy-all.sh

services=(
    "postgresql:configs/postgresql.conf"
    "vaultwarden:configs/vaultwarden.conf"
    "gitea:configs/gitea.conf"
    "wikijs:configs/wikijs.conf"
)

for svc in "${services[@]}"; do
    IFS=: read -r service config <<< "$svc"
    echo "Deploying $service..."
    ./pve-deploy -c "$config" "$service"
done
```

### Custom Install Scripts

Modify install scripts for custom needs:

```bash
# 1. Copy install script
cp community-scripts/install/gitea-install.sh custom-install/

# 2. Modify as needed
nano custom-install/gitea-install.sh

# 3. Update ct script to use custom installer
# Modify community-scripts/ct/gitea.sh to reference your custom script
```

### Integration with Terraform

Use with Terraform for full IaC:

```hcl
resource "null_resource" "deploy_postgresql" {
  provisioner "local-exec" {
    command = "./pve-deploy -c configs/postgresql.conf postgresql"
  }
  
  depends_on = [proxmox_vm_qemu.base_vm]
}
```

## Troubleshooting

### Container Creation Fails

**Error:** "Storage not found"
```bash
# Check available storage
pvesm status

# Use correct storage name
export var_storage="local-lvm"  # or "local-zfs", etc.
```

**Error:** "CT ID already exists"
```bash
# List existing containers
pct list

# Use different ID or leave empty for auto-assign
export var_ctid=""  # Auto-assign
```

**Error:** "Network bridge not found"
```bash
# List bridges
ip link show | grep vmbr

# Use correct bridge
export var_brg="vmbr0"
```

### Service Installation Fails

**Error:** "apt update failed"
```bash
# Enter container
pct enter <ctid>

# Check network
ping -c 3 8.8.8.8

# Check DNS
cat /etc/resolv.conf
```

**Error:** "Compilation failed" (Rust/Cargo)
```bash
# Usually needs more RAM
export var_ram="6144"  # Increase for compilation
```

### Post-Installation Issues

**Can't connect to service:**
```bash
# Check service status
pct enter <ctid>
systemctl status <service>

# Check listening ports
ss -tlnp

# Check firewall on Proxmox host
iptables -L -n
```

**Permission denied:**
```bash
# For unprivileged containers, check UID mapping
cat /etc/subuid
cat /etc/subgid

# Service files should be owned by correct mapped UID
```

### Debugging

Enable verbose mode:
```bash
export var_verbose="yes"
./pve-deploy -c config.conf -v service
```

Check container logs:
```bash
pct enter <ctid>
journalctl -xeu <service>
```

## Additional Resources

- [Community Scripts Documentation](https://helper-scripts.com)
- [Community Scripts GitHub](https://github.com/community-scripts/ProxmoxVE)
- [Proxmox LXC Documentation](https://pve.proxmox.com/wiki/Linux_Container)
- [Community Discord](https://discord.gg/3AnUqsXnmK)
