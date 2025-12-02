# pve-deploy Quick Reference

## Installation

```bash
# Clone community scripts
git clone https://github.com/community-scripts/ProxmoxVE.git community-scripts

# Make wrapper executable
chmod +x pve-deploy
```

## Basic Usage

```bash
# List available services
./pve-deploy --list

# Deploy a service
./pve-deploy -c configs/SERVICE.conf SERVICE

# Dry run
./pve-deploy -c configs/SERVICE.conf --dry-run SERVICE

# Verbose mode
./pve-deploy -c configs/SERVICE.conf -v SERVICE

# Help
./pve-deploy --help
```

## Quick Deploy Examples

### PostgreSQL
```bash
# Interactive (will prompt for version)
echo -e "16\nn" | ./pve-deploy -c configs/postgresql.conf postgresql

# Result: PostgreSQL 16 at 192.168.10.20:5432
```

### Vaultwarden
```bash
./pve-deploy -c configs/vaultwarden.conf vaultwarden

# Takes 20-30 minutes (compiles from source)
# Result: Vaultwarden at https://192.168.10.21:8000
```

### Gitea
```bash
./pve-deploy -c configs/gitea.conf gitea

# Fast (binary installation)
# Result: Gitea at http://192.168.10.22:3000
```

### Wiki.js
```bash
# Requires PostgreSQL deployed first!
./pve-deploy -c configs/wikijs.conf wikijs

# Result: Wiki.js at http://192.168.10.23:3000
```

## Configuration Template

```bash
# Copy template
cp configs/postgresql.conf configs/myservice.conf

# Edit
nano configs/myservice.conf

# Essential variables:
export var_ctid="100"                  # Container ID
export var_hostname="myservice"        # Hostname
export var_cpu="2"                     # CPU cores
export var_ram="4096"                  # RAM (MB)
export var_disk="50"                   # Disk (GB)
export var_storage="local-lvm"         # Storage
export var_unprivileged="1"            # 1=unprivileged
export var_brg="vmbr0"                 # Bridge
export var_net="dhcp"                  # dhcp or ip=x.x.x.x/xx,gw=x.x.x.x
export var_ssh="yes"                   # Enable SSH
```

## Common Post-Install Tasks

### PostgreSQL
```bash
pct enter 100
sudo -u postgres psql

# Create database and user
CREATE DATABASE mydb;
CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypass';
GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
```

### Vaultwarden
```bash
# Access admin panel
https://192.168.10.21:8000/admin

# Set admin token
pct enter 101
nano /opt/vaultwarden/.env
# Add: ADMIN_TOKEN='your-secure-token'
systemctl restart vaultwarden
```

### Gitea
```bash
# Access setup wizard
http://192.168.10.22:3000

# Connect to PostgreSQL
# Host: 192.168.10.20:5432
# User: gitea
# Database: gitea
```

### Wiki.js
```bash
# Access setup wizard
http://192.168.10.23:3000

# Connect to PostgreSQL
# Host: 192.168.10.20:5432
# User: wikijs
# Database: wikijs
```

## Troubleshooting

### Check container status
```bash
pct list                           # List all containers
pct status <ctid>                  # Check specific container
pct enter <ctid>                   # Enter container
```

### Check service
```bash
pct enter <ctid>
systemctl status <service-name>    # Service status
journalctl -xeu <service-name>     # Service logs
ss -tlnp                          # Listening ports
```

### Check Proxmox resources
```bash
pvesm status                       # Storage status
pct config <ctid>                  # Container config
qm list                           # List VMs
```

### Network issues
```bash
pct enter <ctid>
ping -c 3 8.8.8.8                 # Test connectivity
cat /etc/resolv.conf              # Check DNS
ip addr show                      # Check IP
```

## Batch Deployment

```bash
#!/bin/bash
# Deploy full stack

echo "Deploying PostgreSQL..."
echo -e "16\nn" | ./pve-deploy -c configs/postgresql.conf postgresql

echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Create databases
pct exec 100 -- sudo -u postgres psql -c "CREATE DATABASE vaultwarden;"
pct exec 100 -- sudo -u postgres psql -c "CREATE DATABASE gitea;"
pct exec 100 -- sudo -u postgres psql -c "CREATE DATABASE wikijs;"

echo "Deploying Vaultwarden..."
./pve-deploy -c configs/vaultwarden.conf vaultwarden

echo "Deploying Gitea..."
./pve-deploy -c configs/gitea.conf gitea

echo "Deploying Wiki.js..."
./pve-deploy -c configs/wikijs.conf wikijs

echo "Stack deployment complete!"
```

## Service Ports Reference

| Service | Port | Protocol | Access URL |
|---------|------|----------|------------|
| PostgreSQL | 5432 | TCP | postgresql://IP:5432 |
| Vaultwarden | 8000 | HTTPS | https://IP:8000 |
| Gitea | 3000 | HTTP | http://IP:3000 |
| Gitea SSH | 22 | SSH | git@IP:22 |
| Wiki.js | 3000 | HTTP | http://IP:3000 |

## Resource Recommendations

| Service | CPU | RAM | Disk | Type |
|---------|-----|-----|------|------|
| PostgreSQL | 2 | 8GB | 100GB | Unprivileged |
| Vaultwarden | 4* | 6GB* | 20GB | Privileged |
| Gitea | 1 | 2GB | 50GB | Unprivileged |
| Wiki.js | 1 | 2GB | 20GB | Unprivileged |
| Docker | 4 | 8GB | 100GB | Privileged |

*Vaultwarden: High resources needed during compilation, can reduce after deployment

## Environment Variables Quick Reference

```bash
# Container
var_ctid                # Container ID
var_hostname            # Hostname
var_cpu                 # CPU cores
var_ram                 # RAM (MB)
var_disk                # Disk (GB)
var_storage             # Storage location
var_unprivileged        # 1=unprivileged, 0=privileged

# Network
var_brg                 # Bridge (vmbr0)
var_net                 # dhcp or ip=x.x.x.x/xx,gw=x.x.x.x
var_vlan                # VLAN tag
var_gateway             # Gateway IP

# OS
var_os                  # debian, ubuntu, alpine
var_version             # OS version

# Other
var_ssh                 # yes/no
var_ssh_authorized_key  # SSH public key
var_pw                  # Root password
var_verbose             # yes/no
var_tags                # Semicolon-separated tags
```

## ZFS Commands

```bash
# Create dataset
zfs create rpool/postgresql

# Snapshot
zfs snapshot rpool/postgresql@backup-$(date +%Y%m%d)

# List snapshots
zfs list -t snapshot

# Rollback
zfs rollback rpool/postgresql@backup-20250130

# Delete snapshot
zfs destroy rpool/postgresql@backup-20250130
```

## Container Management

```bash
# Start/Stop
pct start <ctid>
pct stop <ctid>
pct shutdown <ctid>

# Backup
vzdump <ctid> --dumpdir /var/lib/vz/dump

# Restore
pct restore <newctid> /var/lib/vz/dump/vzdump-*.tar.zst

# Clone
pct clone <ctid> <newctid> --hostname newname

# Delete
pct destroy <ctid>
```

## Useful One-Liners

```bash
# Get container IP
pct exec <ctid> -- hostname -I

# Execute command in container
pct exec <ctid> -- <command>

# Copy file to container
pct push <ctid> local-file /path/in/container

# Copy file from container
pct pull <ctid> /path/in/container local-file

# Check all container statuses
pct list | awk 'NR>1 {print $1,$3}' | while read id name; do 
    echo "$id ($name): $(pct status $id)"
done

# Show resource usage
pct list | awk 'NR>1 {print $1}' | while read id; do
    echo "=== Container $id ==="
    pct exec $id -- free -h
    pct exec $id -- df -h /
done
```
