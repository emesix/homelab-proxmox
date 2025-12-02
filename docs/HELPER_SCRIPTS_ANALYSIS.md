# Community Helper Scripts - Analysis & Man Pages

**Last Updated:** 2025-11-30  
**Total Scripts:** 396  
**Scripts Analyzed:** Core services for HX310-DB deployment

## Executive Summary

### ⚠️ Critical Findings

1. **Port Usage**
   - Gitea and Wiki.js both use port 3000
   - **Not a problem:** Each container has unique IP address
   - **Reverse proxy** handles external routing by hostname

2. **Network Architecture Mismatch**
   - Scripts create single-network containers
   - Your design requires dual-network (backend + frontend/management)
   - **Mitigation:** Post-deployment network interface addition required

3. **Interactive Prompts**
   - PostgreSQL: Prompts for version selection (15/16/17/18)
   - PostgreSQL: Prompts for Adminer installation (y/N)
   - **Mitigation:** Pipe input or modify install script

4. **Resource Allocation**
   - Vaultwarden default: 4 CPU, 6GB RAM (compilation resources)
   - Can be reduced post-compilation
   - Total HX310-DB allocation will exceed 4 physical cores (acceptable with oversubscription)

5. **Security Concerns**
   - PostgreSQL: Overly permissive pg_hba.conf (0.0.0.0/24 and 0.0.0.0/0)
   - Vaultwarden: Empty ADMIN_TOKEN by default
   - **Action Required:** Secure immediately post-deployment

---

## Service Analysis

### PostgreSQL (CT 100)

#### Purpose
Relational database server providing centralized data storage for Vaultwarden, Gitea, and Wiki.js.

#### Script Details
- **Location:** `community-scripts/ct/postgresql.sh`
- **Install Script:** `community-scripts/install/postgresql-install.sh`
- **Deployment Method:** LXC container (unprivileged by default)

#### Default Resource Allocation
```bash
var_cpu="1"                    # 1 CPU core
var_ram="1024"                 # 1GB RAM
var_disk="4"                   # 4GB disk
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

#### Installation Process
1. **Container Creation** (on Proxmox host)
   - Creates Debian LXC container
   - Configures network interface
   - Sets hostname and resources

2. **PostgreSQL Installation** (inside container)
   - **Interactive Prompt 1:** Version selection (15/16/17/18)
   - Adds PostgreSQL APT repository
   - Installs selected version
   - Creates default cluster
   - Configures pg_hba.conf (client authentication)
   - Configures postgresql.conf (server settings)
   - **Interactive Prompt 2:** Adminer installation (y/N)
   - Starts PostgreSQL service

3. **Configuration Files Created**
   - `/etc/postgresql/<ver>/main/pg_hba.conf` - Client authentication
   - `/etc/postgresql/<ver>/main/postgresql.conf` - Server configuration
   - `/etc/postgresql/<ver>/main/pg_ident.conf` - User mappings

#### Network Configuration
- **Listen Address:** `*` (all interfaces)
- **Port:** 5432 (standard PostgreSQL port)
- **Access Control:** Configured via pg_hba.conf

#### Security Issues
**CRITICAL:** Default pg_hba.conf is overly permissive:
```
host    all    all    0.0.0.0/24     md5
host    all    all    0.0.0.0/0      md5
```

**Recommended:** Restrict to backend VLANs only:
```bash
# After deployment, edit /etc/postgresql/<ver>/main/pg_hba.conf:
host    all    all    10.10.110.0/24    scram-sha-256  # Backend DB VLAN
host    all    all    10.10.100.0/24    scram-sha-256  # Backend services VLAN
host    all    all    10.10.200.0/24    scram-sha-256  # Management VLAN
host    all    all    0.0.0.0/0         reject          # Deny all others
```

#### Post-Deployment Tasks
1. **Secure pg_hba.conf** (restrict access)
2. **Create databases:**
   ```sql
   CREATE DATABASE vaultwarden;
   CREATE USER vaultwarden WITH ENCRYPTED PASSWORD '<secure>';
   GRANT ALL PRIVILEGES ON DATABASE vaultwarden TO vaultwarden;
   
   CREATE DATABASE gitea;
   CREATE USER gitea WITH ENCRYPTED PASSWORD '<secure>';
   GRANT ALL PRIVILEGES ON DATABASE gitea TO gitea;
   
   CREATE DATABASE wikijs;
   CREATE USER wikijs WITH ENCRYPTED PASSWORD '<secure>';
   GRANT ALL PRIVILEGES ON DATABASE wikijs TO wikijs;
   ```
3. **Tune performance** for your RAM allocation
4. **Set up backups** (pg_dump daily)

#### Conflicts & Dependencies
- **No conflicts** - First service to deploy
- **Dependencies:** None (tier 0)
- **Required by:** Vaultwarden, Gitea, Wiki.js

#### Network Requirements
**Current (Staging):**
- Single interface on vmbr0: 192.168.10.20/16

**Future (Production):**
- Primary: VLAN 110 (10.10.110.20) - Database backend
- Secondary: VLAN 200 (10.10.200.100) - Management

---

### Vaultwarden (CT 101)

#### Purpose
Bitwarden-compatible password manager for storing all homelab credentials securely.

#### Script Details
- **Location:** `community-scripts/ct/vaultwarden.sh`
- **Install Script:** `community-scripts/install/vaultwarden-install.sh`
- **Deployment Method:** LXC container (unprivileged)

#### Default Resource Allocation
```bash
var_cpu="4"                    # 4 CPU cores (for Rust compilation)
var_ram="6144"                 # 6GB RAM (for Rust compilation)
var_disk="20"                  # 20GB disk
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

**⚠️ Important:** These high resources are needed during compilation. After deployment, can reduce to:
- CPU: 1 core
- RAM: 2GB

#### Installation Process
1. **Container Creation** (on Proxmox host)
   - Creates Debian LXC container
   - Allocates compilation resources

2. **Dependencies Installation** (inside container)
   - Installs build tools: git, build-essential, pkg-config
   - Installs libraries: libssl-dev, libmariadb-dev-compat, libpq-dev
   - Installs utilities: argon2, ssl-cert

3. **Rust Installation**
   - Downloads rustup installer
   - Installs minimal Rust toolchain
   - Adds cargo to PATH

4. **Vaultwarden Compilation** (~20-30 minutes)
   - Clones vaultwarden repository from GitHub
   - Compiles with features: sqlite, mysql, postgresql
   - Builds in release mode for optimization
   - **This is CPU and RAM intensive**

5. **Service Setup**
   - Creates vaultwarden system user and group
   - Creates directories: `/opt/vaultwarden/{bin,data}`
   - Copies compiled binary to `/opt/vaultwarden/bin/`
   - Downloads web-vault UI from GitHub
   - Creates `.env` configuration file
   - Copies SSL certificates (self-signed)
   - Creates systemd service
   - Enables and starts vaultwarden service

#### Configuration Files Created
- `/opt/vaultwarden/.env` - Environment variables
- `/opt/vaultwarden/bin/vaultwarden` - Compiled binary
- `/opt/vaultwarden/web-vault/` - Web UI
- `/opt/vaultwarden/data/` - Database and uploads
- `/etc/systemd/system/vaultwarden.service` - Systemd unit

#### Network Configuration
- **Listen Address:** 0.0.0.0 (all interfaces)
- **HTTP Port:** Not exposed (disabled)
- **HTTPS Port:** 8000
- **Protocol:** HTTPS only (with TLS)

#### Security Issues
**CRITICAL:** Empty ADMIN_TOKEN by default:
```bash
ADMIN_TOKEN=''
```

**Required Actions:**
1. **Set admin token immediately:**
   ```bash
   # Generate secure token
   openssl rand -base64 32
   
   # Hash it (Argon2)
   echo -n "your-token" | argon2 "$(openssl rand -base64 32)" -t 2 -m 16 -p 4 -l 64 -e
   
   # Edit /opt/vaultwarden/.env
   ADMIN_TOKEN='$argon2id$...'
   
   # Restart service
   systemctl restart vaultwarden
   ```

2. **Disable signups after creating account**
3. **Configure PostgreSQL database** (optional, default is SQLite)
4. **Set up regular exports**

#### Post-Deployment Tasks
1. **Access:** https://192.168.10.21:8000
2. **Create your primary account** (first user becomes admin)
3. **Set ADMIN_TOKEN** in /opt/vaultwarden/.env
4. **Access admin panel:** https://192.168.10.21:8000/admin
5. **Disable public signups**
6. **Store all PostgreSQL credentials** from pg-brein
7. **Export vault** and store backup securely
8. **Test backup restore** procedure

#### Database Options
**Default:** SQLite (file-based, stored in /opt/vaultwarden/data/db.sqlite3)

**PostgreSQL (Recommended for production):**
```bash
# Edit /opt/vaultwarden/.env
DATABASE_URL=postgresql://vaultwarden:<password>@192.168.10.20:5432/vaultwarden

# Restart
systemctl restart vaultwarden
```

**Benefits of PostgreSQL:**
- Better concurrent access
- Easier backups (pg_dump)
- Better performance at scale

#### Conflicts & Dependencies
- **No port conflicts**
- **Dependencies:** PostgreSQL (optional, for database)
- **Blocks:** Nothing (but needed for storing credentials)

#### Network Requirements
**Current (Staging):**
- Single interface on vmbr0: 192.168.10.21/16

**Future (Production):**
- Primary: VLAN 100 (10.10.100.21) - Backend services
- Secondary: VLAN 40 (10.10.40.21) - DMZ (via reverse proxy)
- Tertiary: VLAN 200 (10.10.200.101) - Management

---

### Gitea (CT 102)

#### Purpose
Lightweight self-hosted Git service for mirroring GitHub repositories locally.

#### Script Details
- **Location:** `community-scripts/ct/gitea.sh`
- **Install Script:** `community-scripts/install/gitea-install.sh`
- **Deployment Method:** LXC container (unprivileged), binary installation

#### Default Resource Allocation
```bash
var_cpu="1"                    # 1 CPU core
var_ram="1024"                 # 1GB RAM
var_disk="8"                   # 8GB disk (increase for repos)
var_os="debian"
var_version="12"               # Debian 12
var_unprivileged="1"           # Unprivileged container
```

**⚠️ Recommended:** Increase disk for repository storage:
```bash
var_disk="50"                  # 50GB for repositories
```

#### Installation Process
1. **Container Creation** (on Proxmox host)
   - Creates Debian LXC container
   - Minimal resources (efficient binary)

2. **Dependencies Installation** (inside container)
   - Installs git
   - Installs sqlite3

3. **Gitea Binary Installation**
   - Downloads latest Gitea binary from GitHub releases
   - Installs to `/usr/local/bin/gitea`
   - Makes executable

4. **Service Setup**
   - Creates gitea system user and group
   - Creates directories: `/var/lib/gitea/{custom,data,log}`
   - Creates config directory: `/etc/gitea`
   - Sets permissions (770 on /etc/gitea for setup)
   - Creates systemd service
   - Enables and starts gitea service

#### Configuration Files Created
- `/usr/local/bin/gitea` - Binary
- `/etc/gitea/app.ini` - Configuration (created during web setup)
- `/var/lib/gitea/data/` - Repositories and database
- `/var/lib/gitea/log/` - Logs
- `/etc/systemd/system/gitea.service` - Systemd unit

#### Network Configuration
- **HTTP Port:** 3000
- **SSH Port:** 22 (for git operations)
- **Protocol:** HTTP (use reverse proxy for HTTPS)

#### Port Usage
**No conflict:** Each container has its own IP address

**Access Methods:**
1. **Direct access** (staging/internal)
   - Gitea: http://192.168.10.22:3000 (staging)
   - Gitea: http://10.10.100.22:3000 (production)

2. **Reverse proxy** (external/DMZ)
   - Reverse proxy on DMZ routes by hostname
   - Gitea: gitea.homelab.local → 10.10.100.22:3000
   - Wiki.js: wiki.homelab.local → 10.10.100.23:3000
   - Users access via friendly hostnames
   - SSL/TLS termination at proxy

#### Post-Deployment Tasks
1. **Access setup wizard:** http://192.168.10.22:3000
2. **Database Configuration:**
   - Type: PostgreSQL
   - Host: 192.168.10.20:5432
   - User: gitea
   - Password: (from Vaultwarden)
   - Database: gitea
3. **General Settings:**
   - Site Title: "Homelab Gitea"
   - Repository Root Path: /var/lib/gitea/data/repositories
   - Git LFS Root Path: /var/lib/gitea/data/lfs
   - Run As Username: gitea
4. **Server Settings:**
   - SSH Server Domain: 192.168.10.22 (or hostname)
   - SSH Port: 22
   - HTTP Listen Port: 3000
   - Application URL: http://192.168.10.22:3000/
5. **Admin Account Creation:** Store in Vaultwarden
6. **Mirror GitHub repositories:**
   - New Migration → GitHub
   - Repository: emesix/Proxmox-Based-Homelab
   - Make it a mirror (sync automatically)

#### Git Operations
**SSH Access for git push/pull:**
```bash
# Clone via SSH
git clone ssh://git@192.168.10.22:22/homelab/proxmox-homelab.git

# Configure remote
git remote add homelab ssh://git@192.168.10.22:22/homelab/proxmox-homelab.git

# Push/pull
git push homelab main
```

**HTTP Access:**
```bash
# Clone via HTTP
git clone http://192.168.10.22:3000/homelab/proxmox-homelab.git
```

#### Conflicts & Dependencies
- **No conflicts:** Unique IP address eliminates port conflicts
- **Dependencies:** PostgreSQL (for database)
- **Blocks:** Nothing

#### Network Requirements
**Current (Staging):**
- Single interface on vmbr0: 192.168.10.22/16

**Future (Production):**
- Primary: VLAN 100 (10.10.100.22) - Backend services
- Secondary: VLAN 40 (10.10.40.22) - DMZ (via reverse proxy)
- Tertiary: VLAN 200 (10.10.200.102) - Management

---

### Wiki.js (CT 103)

#### Purpose
Modern documentation platform with Git sync for homelab knowledge base.

#### Script Details
- **Location:** `community-scripts/ct/wikijs.sh`
- **Install Script:** `community-scripts/install/wikijs-install.sh`
- **Deployment Method:** LXC container (unprivileged), Node.js application

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="2048"                 # 2GB RAM
var_disk="10"                  # 10GB disk
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

#### Installation Process
1. **Container Creation** (on Proxmox host)
   - Creates Debian LXC container
   - Allocates Node.js resources

2. **Node.js Setup** (inside container)
   - Installs Node.js version 22
   - Installs yarn and node-gyp

3. **Wiki.js Installation**
   - Downloads Wiki.js from GitHub releases
   - Extracts to `/opt/wikijs`
   - Installs dependencies via npm

4. **Service Setup**
   - Creates config.yml configuration
   - Creates systemd service
   - Enables and starts wikijs service

#### Configuration Files Created
- `/opt/wikijs/` - Application directory
- `/opt/wikijs/config.yml` - Initial configuration
- `/opt/wikijs/data/` - Database and uploads
- `/etc/systemd/system/wikijs.service` - Systemd unit

#### Network Configuration
- **HTTP Port:** 3000
- **Protocol:** HTTP (use reverse proxy for HTTPS)

#### Port Usage
**No conflict:** Each container has its own IP address (see Gitea section for access methods)

#### Database Requirement
**CRITICAL:** Wiki.js v3.x+ does NOT support SQLite

**Supported databases:**
- PostgreSQL (recommended)
- MySQL/MariaDB
- MS SQL Server

**Required:** PostgreSQL database must exist before setup

#### Post-Deployment Tasks
1. **Access setup wizard:** http://192.168.10.23:3000
2. **Database Configuration:**
   - Type: PostgreSQL
   - Host: 192.168.10.20
   - Port: 5432
   - Database: wikijs
   - Username: wikijs
   - Password: (from Vaultwarden)
3. **Site Configuration:**
   - Site URL: http://192.168.10.23:3000
   - Language: English
   - Email: admin@homelab.local
4. **Admin Account:** Store in Vaultwarden
5. **Configure Git Sync:**
   - Administration → Storage → Git
   - Auth Type: Basic
   - Repository URL: http://192.168.10.22:3000/homelab/proxmox-homelab.git
   - Branch: main
   - Username: (Gitea user)
   - Password: (from Vaultwarden)
   - Sync Direction: Pull only (GitHub is SSoT)
   - Sync Interval: 1 hour
   - Local Repository Path: ./data/repo
6. **Import Documentation:**
   - Trigger initial sync
   - Verify docs/ folder structure appears
   - Check markdown rendering

#### Git Sync Behavior
**Sync Flow:**
```
GitHub (SSoT) → Gitea (mirror) → Wiki.js (display)
```

**Sync Schedule:**
- Gitea pulls from GitHub: hourly
- Wiki.js pulls from Gitea: hourly
- Max delay: 2 hours for changes to appear

**Conflict Resolution:**
- Pull-only mode: never conflicts
- Wiki changes via web UI NOT pushed back
- Edit in GitHub or Gitea only

#### Conflicts & Dependencies
- **No conflicts:** Unique IP address eliminates port conflicts
- **Dependencies:** PostgreSQL (required), Gitea (for Git sync)
- **Blocked by:** PostgreSQL must exist, Gitea must be running

#### Network Requirements
**Current (Staging):**
- Single interface on vmbr0: 192.168.10.23/16

**Future (Production):**
- Primary: VLAN 100 (10.10.100.23) - Backend services
- Secondary: VLAN 40 (10.10.40.23) - DMZ (via reverse proxy)
- Tertiary: VLAN 200 (10.10.200.103) - Management

---

## Deployment Order

### Critical Path
```
1. PostgreSQL (CT 100)
   ↓
2. Vaultwarden (CT 101) ← Can run parallel with 3 & 4
   ↓
3. Gitea (CT 102)
   ↓
4. Wiki.js (CT 103)
```

**Rationale:**
1. **PostgreSQL first** - Required by all others
2. **Vaultwarden second** - Needed to store credentials
3. **Gitea third** - Source for Wiki.js sync
4. **Wiki.js last** - Depends on both PostgreSQL and Gitea

### Parallel Deployment
After PostgreSQL is ready, can deploy in parallel:
- Vaultwarden (independent)
- Gitea (only needs PostgreSQL)

Wiki.js must wait for both Gitea and PostgreSQL.

---

## Port Assignment Summary

| Service | Port | Protocol | IP Address | Notes |
|---------|------|----------|------------|-------|
| PostgreSQL | 5432 | TCP | 192.168.10.20 (staging)<br>10.10.110.20 (prod) | Backend only |
| Vaultwarden | 8000 | HTTPS | 192.168.10.21 (staging)<br>10.10.100.21 (prod) | Self-signed cert |
| Gitea | 3000 | HTTP | 192.168.10.22 (staging)<br>10.10.100.22 (prod) | Web UI |
| Gitea | 22 | SSH | 192.168.10.22 (staging)<br>10.10.100.22 (prod) | Git operations |
| Wiki.js | 3000 | HTTP | 192.168.10.23 (staging)<br>10.10.100.23 (prod) | Web UI |

**No Port Conflicts:** Each container has a unique IP address, so multiple services can use the same port numbers.

### Reverse Proxy Configuration
For external access, deploy Nginx or Traefik on DMZ (VLAN 40) to route by hostname:
```nginx
# Gitea
server {
    listen 80;
    server_name gitea.homelab.local;
    location / {
        proxy_pass http://10.10.100.22:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Wiki.js
server {
    listen 80;
    server_name wiki.homelab.local;
    location / {
        proxy_pass http://10.10.100.23:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Vaultwarden
server {
    listen 443 ssl;
    server_name vault.homelab.local;
    
    ssl_certificate /etc/ssl/certs/homelab.crt;
    ssl_certificate_key /etc/ssl/private/homelab.key;
    
    location / {
        proxy_pass https://10.10.100.21:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Resource Summary

### Total Allocation (HX310-DB)
| Resource | PostgreSQL | Vaultwarden | Gitea | Wiki.js | **Total** | **Available** |
|----------|------------|-------------|-------|---------|-----------|---------------|
| CPU | 2 | 1 | 1 | 2 | **6 cores** | 4 cores |
| RAM | 8GB | 2GB | 2GB | 2GB | **14GB** | 32GB |
| Disk | 100GB | 20GB | 50GB | 20GB | **190GB** | ~1.9TB |

**CPU Oversubscription:** 6 virtual cores on 4 physical cores (150%) - **ACCEPTABLE**
- Services won't all peak simultaneously
- Database and web apps have different usage patterns
- Proxmox handles scheduling efficiently

**RAM Utilization:** 14GB / 32GB (44%) - **OPTIMAL**
- Leaves headroom for peaks
- Can increase PostgreSQL shared_buffers if needed

**Disk Usage:** 190GB / 1.9TB (10%) - **EXCELLENT**
- Plenty of room for growth
- Can increase Gitea repos space
- ZFS compression will help

---

## Network Architecture Issues

### Current Script Limitation
All helper scripts create **single-network** containers:
```bash
export var_net="ip=192.168.10.20/16,gw=192.168.10.1"
```

### Your Architecture Requires
**Dual or triple networks per service:**
- Backend network (VLAN 100 or 110)
- DMZ/Frontend network (VLAN 40) - for web-accessible services
- Management network (VLAN 200) - for SSH/admin

### Solution: Post-Deployment Network Addition
**After each container is created:**
```bash
# Example: Add management interface to PostgreSQL
pct set 100 -net1 name=eth1,bridge=vmbr0,tag=200,firewall=1

# Inside container, configure /etc/network/interfaces
auto eth1
iface eth1 inet static
    address 10.10.200.100/24
```

**See:** `docs/NETWORK-ARCHITECTURE.md` for complete dual-network setup guide

---

## Security Checklist

### PostgreSQL
- [ ] Restrict pg_hba.conf to backend VLANs only
- [ ] Set strong passwords for all database users
- [ ] Enable SSL/TLS for connections
- [ ] Configure regular backups (pg_dump)
- [ ] Tune shared_buffers and other settings
- [ ] Monitor pg_stat_activity

### Vaultwarden
- [ ] Set ADMIN_TOKEN immediately
- [ ] Create your primary account
- [ ] Disable public signups
- [ ] Export vault backup
- [ ] Consider PostgreSQL database instead of SQLite
- [ ] Set up SMTP for password resets (optional)
- [ ] Enable 2FA for admin account

### Gitea
- [ ] Store admin credentials in Vaultwarden
- [ ] Disable public registration after setup
- [ ] Configure SSH keys for git operations
- [ ] Set up repository mirroring
- [ ] Enable HTTPS via reverse proxy
- [ ] Regular backups of /var/lib/gitea

### Wiki.js
- [ ] Store admin credentials in Vaultwarden
- [ ] Configure Git sync (pull-only)
- [ ] Set appropriate user permissions
- [ ] Enable HTTPS via reverse proxy
- [ ] Regular database backups (via PostgreSQL)

---

## Common Issues & Solutions

### Issue: PostgreSQL won't accept remote connections
**Symptoms:** Connection refused from other containers

**Solution:**
```bash
# Check pg_hba.conf allows the source IP
pct exec 100 -- cat /etc/postgresql/16/main/pg_hba.conf

# Check PostgreSQL is listening on all interfaces
pct exec 100 -- grep listen_addresses /etc/postgresql/16/main/postgresql.conf

# Should show: listen_addresses = '*'

# Restart PostgreSQL
pct exec 100 -- systemctl restart postgresql
```

### Issue: Vaultwarden compilation fails
**Symptoms:** Out of memory, cargo build error

**Solution:**
```bash
# Increase container RAM temporarily
pct set 101 -memory 8192

# Restart container
pct reboot 101

# Re-run compilation (inside container)
cd ~/vaultwarden
cargo build --features "sqlite,mysql,postgresql" --release

# After successful build, reduce RAM
pct set 101 -memory 2048
```

### Issue: Can't access services by hostname
**Symptoms:** gitea.homelab.local doesn't resolve

**Solution:** Configure DNS and reverse proxy
```bash
# Option 1: Add to /etc/hosts on client machines
10.10.40.10  gitea.homelab.local wiki.homelab.local vault.homelab.local

# Option 2: Configure DNS server (pfSense/OPNsense)
# Add A records pointing to reverse proxy IP (10.10.40.10)
```

### Issue: Wiki.js can't connect to Gitea
**Symptoms:** Git sync fails, connection refused

**Solution:**
```bash
# Verify Gitea is running
pct exec 102 -- systemctl status gitea

# Test connectivity from Wiki.js container
pct exec 103 -- curl -I http://192.168.10.22:3000

# Check firewall isn't blocking
pct exec 103 -- telnet 192.168.10.22 3000
```

### Issue: Services don't survive reboot
**Symptoms:** After host reboot, services are down

**Solution:**
```bash
# Enable autostart for containers
pct set 100 -onboot 1  # PostgreSQL
pct set 101 -onboot 1  # Vaultwarden
pct set 102 -onboot 1  # Gitea
pct set 103 -onboot 1  # Wiki.js

# Set start order (PostgreSQL first)
pct set 100 -startup order=1
pct set 101 -startup order=2
pct set 102 -startup order=3
pct set 103 -startup order=4
```

---

## Related Documentation

- **Configuration Guide:** `docs/COMMUNITY_SCRIPTS_GUIDE.md`
- **Quick Reference:** `docs/QUICK_REFERENCE.md`
- **Network Architecture:** `docs/NETWORK-ARCHITECTURE.md`
- **Integration Summary:** `docs/PVE-DEPLOY-INTEGRATION.md`
- **Deployment Plan:** Warp Drive Notebook - HX310-DB Core Services Deployment

---

## Appendix: Full Variable Reference

### Common Variables (All Scripts)
```bash
# Container Identity
export var_ctid="100"              # Container ID (auto if empty)
export var_hostname="service"      # Hostname

# Resources
export var_cpu="2"                 # CPU cores
export var_ram="4096"              # RAM in MB
export var_disk="50"               # Disk in GB
export var_storage="local-lvm"     # Storage location

# Container Type
export var_unprivileged="1"        # 1=unprivileged, 0=privileged

# OS
export var_os="debian"             # debian, ubuntu, alpine
export var_version="12"            # OS version

# Network
export var_brg="vmbr0"             # Bridge interface
export var_net="dhcp"              # dhcp or ip=x.x.x.x/xx,gw=x.x.x.x
export var_gateway="192.168.10.1"  # Gateway IP
export var_vlan=""                 # VLAN tag (optional)
export var_mac=""                  # MAC address (optional)

# Other
export var_ssh="yes"               # Enable SSH
export var_pw=""                   # Root password (auto if empty)
export var_verbose="no"            # Verbose output
export var_tags="tag1;tag2"        # Semicolon-separated tags
```

### Service-Specific Defaults
```bash
# PostgreSQL
var_cpu="1"
var_ram="1024"
var_disk="4"

# Vaultwarden
var_cpu="4"      # High for compilation
var_ram="6144"   # High for compilation
var_disk="20"

# Gitea
var_cpu="1"
var_ram="1024"
var_disk="8"

# Wiki.js
var_cpu="2"
var_ram="2048"
var_disk="10"
```

---

## Helper Script Usage (Man Pages)

This section documents how to use the community helper scripts to deploy services.

### General Script Usage

All helper scripts follow the same pattern:

```bash
# Basic usage (interactive)
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/<script-name>.sh)"

# With pve-deploy wrapper
pve-deploy /path/to/config.conf

# With environment variables (non-interactive)
export var_ctid="100"
export var_hostname="prowlarr"
export var_cpu="2"
export var_ram="1024"
export var_disk="4"
export var_net="ip=192.168.10.20/16,gw=192.168.10.1"
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/prowlarr.sh)"
```

### Environment Variables Reference

All scripts accept these variables:

```bash
# Container Identity
var_ctid="100"                  # Container ID (auto-assigned if empty)
var_hostname="service"          # Hostname
var_tags="tag1;tag2"            # Semicolon-separated tags

# Resources
var_cpu="2"                     # CPU cores
var_ram="2048"                  # RAM in MB
var_disk="8"                    # Disk size in GB
var_storage="local-lvm"         # Storage location

# Container Type
var_unprivileged="1"            # 1=unprivileged (default), 0=privileged

# Operating System
var_os="debian"                 # debian, ubuntu, alpine
var_version="13"                # OS version

# Network
var_brg="vmbr0"                 # Bridge interface
var_net="dhcp"                  # dhcp OR ip=x.x.x.x/xx,gw=x.x.x.x
var_gateway="192.168.10.1"     # Gateway (used with static IP)
var_vlan=""                     # VLAN tag (optional)
var_mac=""                      # MAC address (optional)

# Other
var_ssh="yes"                   # Enable SSH (default: yes)
var_pw=""                       # Root password (auto-generated if empty)
var_verbose="no"                # Verbose output (default: no)
```

### Script Behavior

**Interactive Mode:** If variables are not set, scripts will prompt for:
- Container ID (or auto-assign)
- Hostname
- Resources (shows defaults, press Enter to accept)
- Network configuration

**Non-Interactive Mode:** All variables set = no prompts

**Update Function:** All scripts include `update_script()` function:
```bash
# To update an existing container
pct exec <ctid> -- bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/<script>.sh)" -- update
```

---

## ARR Suite Services

### Prowlarr (Indexer Manager)

#### Purpose
Centralized indexer management for all *arr applications. Manages connections to torrent trackers and Usenet indexers, syncing them to Sonarr, Radarr, Lidarr, and Readarr.

#### Script Details
- **Location:** `community-scripts/ct/prowlarr.sh`
- **Install Script:** `community-scripts/install/prowlarr-install.sh`
- **Deployment Method:** LXC container, binary installation

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="1024"                 # 1GB RAM
var_disk="4"                   # 4GB disk
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

#### Installation Process
1. **Dependencies:** sqlite3
2. **Binary Installation:** Downloads from Prowlarr/Prowlarr GitHub releases
3. **Installation Path:** `/opt/Prowlarr` (binary), `/var/lib/prowlarr/` (data)
4. **Systemd Service:** prowlarr.service
5. **Installation Time:** ~2-3 minutes (fast binary install)

#### Network Configuration
- **Port:** 9696
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0 (all interfaces)

#### Post-Deployment Tasks
1. **Access:** http://192.168.10.xx:9696
2. **Add Indexers:** Configure torrent trackers and Usenet indexers
3. **Connect Apps:** Sync indexers to Sonarr, Radarr, Lidarr, Readarr
4. **API Keys:** Generate and store in Vaultwarden
5. **Test Search:** Verify indexers are working

#### Dependencies & Integration
- **Dependencies:** None (tier 0 for ARR suite)
- **Used by:** Sonarr, Radarr, Lidarr, Readarr
- **Deploy First:** Must be deployed before other *arr apps

---

### Sonarr (TV Shows)

#### Purpose
Automated TV show management - monitors, downloads, and organizes TV episodes.

#### Script Details
- **Location:** `community-scripts/ct/sonarr.sh`
- **Install Script:** `community-scripts/install/sonarr-install.sh`
- **Deployment Method:** LXC container, binary installation

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="1024"                 # 1GB RAM
var_disk="4"                   # 4GB disk (metadata only)
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

**⚠️ Note:** Disk is for metadata only. Media stored on network share.

#### Installation Process
1. **Dependencies:** sqlite3
2. **Binary Installation:** Downloads Sonarr v4 from services.sonarr.tv
3. **Installation Path:** `/opt/Sonarr` (binary), `/var/lib/sonarr/` (data)
4. **Systemd Service:** sonarr.service
5. **Installation Time:** ~2-3 minutes

#### Network Configuration
- **Port:** 8989
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0

#### Post-Deployment Tasks
1. **Access:** http://192.168.10.xx:8989
2. **Connect Prowlarr:** Settings → Indexers → Add from Prowlarr
3. **Connect Download Client:** qBittorrent or SABnzbd
4. **Add Root Folder:** Mount point for TV shows (e.g., /mnt/media/tv)
5. **Add Shows:** Import existing library or add new shows
6. **Quality Profiles:** Configure preferred quality (1080p, 4K, etc.)
7. **API Key:** Store in Vaultwarden

#### Storage Requirements
**Critical:** Requires network share mount for media storage
```bash
# Example mount in container
auto /mnt/media
iface /mnt/media inet manual
    # Mount via NFS or SMB from storage server
```

#### Dependencies & Integration
- **Dependencies:** Prowlarr (indexers), qBittorrent/SABnzbd (downloads)
- **Integrates with:** Overseerr (requests), Bazarr (subtitles)
- **Network share:** REQUIRED for media storage

---

### Radarr (Movies)

#### Purpose
Automated movie management - monitors, downloads, and organizes movies.

#### Script Details
- **Location:** `community-scripts/ct/radarr.sh`
- **Install Script:** `community-scripts/install/radarr-install.sh`
- **Deployment Method:** LXC container, binary installation

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="1024"                 # 1GB RAM
var_disk="4"                   # 4GB disk (metadata only)
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

#### Installation Process
1. **Dependencies:** sqlite3
2. **Binary Installation:** Downloads from Radarr/Radarr GitHub releases
3. **Installation Path:** `/opt/Radarr` (binary), `/var/lib/radarr/` (data)
4. **Systemd Service:** radarr.service
5. **Installation Time:** ~2-3 minutes

#### Network Configuration
- **Port:** 7878
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0

#### Post-Deployment Tasks
1. **Access:** http://192.168.10.xx:7878
2. **Connect Prowlarr:** Settings → Indexers → Add from Prowlarr
3. **Connect Download Client:** qBittorrent or SABnzbd
4. **Add Root Folder:** Mount point for movies (e.g., /mnt/media/movies)
5. **Add Movies:** Import existing library or add new movies
6. **Quality Profiles:** Configure preferred quality
7. **API Key:** Store in Vaultwarden

#### Dependencies & Integration
- **Dependencies:** Prowlarr (indexers), qBittorrent/SABnzbd (downloads)
- **Integrates with:** Overseerr (requests), Bazarr (subtitles)
- **Network share:** REQUIRED for media storage

---

### Lidarr (Music)

#### Purpose
Automated music management - monitors, downloads, and organizes music albums.

#### Script Details
- **Location:** `community-scripts/ct/lidarr.sh`
- **Install Script:** `community-scripts/install/lidarr-install.sh`
- **Deployment Method:** LXC container, binary installation

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="1024"                 # 1GB RAM
var_disk="4"                   # 4GB disk (metadata only)
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

#### Installation Process
1. **Dependencies:** sqlite3, libchromaprint-tools, mediainfo
2. **Binary Installation:** Downloads from Lidarr/Lidarr GitHub releases
3. **Installation Path:** `/opt/Lidarr` (binary), `/var/lib/lidarr/` (data)
4. **Systemd Service:** lidarr.service
5. **Installation Time:** ~2-3 minutes

#### Network Configuration
- **Port:** 8686
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0

#### Post-Deployment Tasks
Same as Sonarr/Radarr but for music:
1. **Access:** http://192.168.10.xx:8686
2. **Connect Prowlarr**
3. **Connect Download Client**
4. **Add Root Folder:** /mnt/media/music
5. **Add Artists/Albums**
6. **Configure Metadata:** MusicBrainz integration
7. **API Key:** Store in Vaultwarden

#### Dependencies & Integration
- **Dependencies:** Prowlarr (indexers), qBittorrent/SABnzbd (downloads)
- **Integrates with:** Navidrome or Plex for playback
- **Network share:** REQUIRED for media storage

---

### Readarr (Books)

#### Purpose
Automated book/audiobook management - monitors, downloads, and organizes ebooks and audiobooks.

#### Script Details
- **Location:** `community-scripts/ct/readarr.sh`
- **Install Script:** `community-scripts/install/readarr-install.sh`
- **Deployment Method:** LXC container, binary installation

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="1024"                 # 1GB RAM
var_disk="4"                   # 4GB disk (metadata only)
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

#### Installation Process
1. **Dependencies:** sqlite3
2. **Binary Installation:** Downloads from readarr.servarr.com
3. **Installation Path:** `/opt/Readarr` (binary), `/var/lib/readarr/` (data)
4. **Systemd Service:** readarr.service
5. **Installation Time:** ~2-3 minutes

#### Network Configuration
- **Port:** 8787
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0

#### Post-Deployment Tasks
Same as other *arr apps but for books:
1. **Access:** http://192.168.10.xx:8787
2. **Connect Prowlarr**
3. **Connect Download Client**
4. **Add Root Folders:** /mnt/media/books, /mnt/media/audiobooks
5. **Add Authors/Books**
6. **Configure Metadata:** Goodreads/Calibre integration
7. **API Key:** Store in Vaultwarden

#### Dependencies & Integration
- **Dependencies:** Prowlarr (indexers), qBittorrent/SABnzbd (downloads)
- **Integrates with:** Calibre-web for reading
- **Network share:** REQUIRED for media storage

---

### Bazarr (Subtitles)

#### Purpose
Automated subtitle management - downloads and manages subtitles for Sonarr and Radarr content.

#### Script Details
- **Location:** `community-scripts/ct/bazarr.sh`
- **Install Script:** `community-scripts/install/bazarr-install.sh`
- **Deployment Method:** LXC container, Python application

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="1024"                 # 1GB RAM
var_disk="4"                   # 4GB disk
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

#### Installation Process
1. **Python Setup:** Uses uv with Python 3.12
2. **Download:** Fetches from morpheus65535/bazarr GitHub releases
3. **Virtual Environment:** Creates `/opt/bazarr/venv`
4. **Dependencies:** Installs Python packages via uv pip
5. **Installation Path:** `/opt/bazarr` (app), `/var/lib/bazarr/` (data)
6. **Systemd Service:** bazarr.service
7. **Installation Time:** ~3-5 minutes (Python dependencies)

#### Network Configuration
- **Port:** 6767
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0

#### Post-Deployment Tasks
1. **Access:** http://192.168.10.xx:6767
2. **Connect Sonarr:** Settings → Sonarr (API key, URL)
3. **Connect Radarr:** Settings → Radarr (API key, URL)
4. **Add Subtitle Providers:** OpenSubtitles, Subscene, etc.
5. **Configure Languages:** Preferred subtitle languages
6. **Sync Interval:** How often to check for subtitles
7. **Path Mappings:** If Bazarr and Sonarr/Radarr see storage differently

#### Dependencies & Integration
- **Dependencies:** Sonarr (TV), Radarr (Movies)
- **Requires:** Same network share access as Sonarr/Radarr
- **Reads metadata from:** Sonarr/Radarr databases

---

### Overseerr (Request Management)

#### Purpose
Media request and discovery platform. Users can request movies/TV shows, which get automatically sent to Sonarr/Radarr.

#### Script Details
- **Location:** `community-scripts/ct/overseerr.sh`
- **Install Script:** `community-scripts/install/overseerr-install.sh`
- **Deployment Method:** LXC container, Node.js application

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="4096"                 # 4GB RAM (higher for Node.js build)
var_ram="2048"                 # 2GB RAM (can reduce after build)
var_disk="8"                   # 8GB disk
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

**⚠️ Important:** Initial build requires 4GB RAM. Can reduce to 2GB post-deployment.

#### Installation Process
1. **Node.js Setup:** Installs Node.js 22, yarn
2. **Download:** Fetches from sct/overseerr GitHub releases
3. **Build Process:** Runs `yarn install` and `yarn build` (~5-10 minutes)
4. **Installation Path:** `/opt/overseerr`
5. **Systemd Service:** overseerr.service
6. **Installation Time:** ~10-15 minutes (Node.js build is slow)

#### Network Configuration
- **Port:** 5055
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0

#### Post-Deployment Tasks
1. **Access:** http://192.168.10.xx:5055
2. **Initial Setup Wizard:**
   - Connect to Plex/Jellyfin (for user authentication)
   - Connect Sonarr (TV requests)
   - Connect Radarr (movie requests)
3. **Configure Request Rules:**
   - Auto-approval for trusted users
   - Quality profiles per user
   - Request limits
4. **User Management:** Invite users or enable Plex/Jellyfin auth
5. **Notifications:** Discord, Slack, email, etc.
6. **Reduce RAM:** `pct set <ctid> -memory 2048` after build

#### Dependencies & Integration
- **Dependencies:** Sonarr (TV), Radarr (movies), Plex/Jellyfin (optional auth)
- **User-facing:** Meant to be accessible from frontend network
- **Most important for multi-user setups**

---

### qBittorrent (Torrent Client)

#### Purpose
BitTorrent client for downloading torrents. Used by all *arr applications.

#### Script Details
- **Location:** `community-scripts/ct/qbittorrent.sh`
- **Install Script:** `community-scripts/install/qbittorrent-install.sh`
- **Deployment Method:** LXC container, static binary

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="2048"                 # 2GB RAM
var_disk="8"                   # 8GB disk (torrents metadata)
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

**⚠️ Note:** Disk is for torrent metadata. Media downloads go to network share.

#### Installation Process
1. **Binary Download:** Static binary from userdocs/qbittorrent-nox-static
2. **Installation Path:** `/opt/qbittorrent/qbittorrent-nox`
3. **Pre-configured:** Default admin credentials set
4. **Systemd Service:** qbittorrent-nox.service
5. **Installation Time:** ~1-2 minutes (fast static binary)

#### Network Configuration
- **Web UI Port:** 8090
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0
- **BitTorrent Ports:** 6881-6889 (default, configurable)

#### Default Credentials
**Username:** admin  
**Password:** adminadmin

**⚠️ CHANGE IMMEDIATELY** after first login!

#### Post-Deployment Tasks
1. **Access:** http://192.168.10.xx:8090
2. **Login:** admin / adminadmin
3. **Change Password:** Tools → Options → Web UI
4. **Configure Paths:**
   - Default Save Path: /mnt/downloads (network share)
   - Temp Path: /mnt/downloads/incomplete
5. **Connection Settings:**
   - Port: 6881 (or random)
   - UPnP/NAT-PMP: disabled (firewall handles it)
6. **Speed Limits:** Set upload/download limits if needed
7. **API Key:** Not needed (username/password auth)
8. **Storage Credentials:** Store in Vaultwarden

#### Storage Requirements
**Critical:** Requires network share for downloads
```bash
# Must mount network share in container
auto /mnt/downloads
iface /mnt/downloads inet manual
```

#### Dependencies & Integration
- **Dependencies:** Network share for downloads
- **Used by:** Sonarr, Radarr, Lidarr, Readarr
- **Configure in *arr apps:** Settings → Download Clients → qBittorrent

---

### SABnzbd (Usenet Client)

#### Purpose
Usenet (NZB) downloader. Alternative to torrents, requires Usenet provider subscription.

#### Script Details
- **Location:** `community-scripts/ct/sabnzbd.sh`
- **Install Script:** `community-scripts/install/sabnzbd-install.sh`
- **Deployment Method:** LXC container, Python application

#### Default Resource Allocation
```bash
var_cpu="2"                    # 2 CPU cores
var_ram="2048"                 # 2GB RAM
var_disk="5"                   # 5GB disk
var_os="debian"
var_version="13"               # Debian 13
var_unprivileged="1"           # Unprivileged container
```

#### Installation Process
1. **Dependencies:** par2 (repair), p7zip-full (extraction), unrar
2. **Python Setup:** Uses uv with Python 3.13
3. **Download:** Fetches from sabnzbd/sabnzbd GitHub releases
4. **Virtual Environment:** Creates `/opt/sabnzbd/venv`
5. **Optional:** par2cmdline-turbo (faster repair, interactive prompt)
6. **Installation Path:** `/opt/sabnzbd`
7. **Systemd Service:** sabnzbd.service
8. **Installation Time:** ~5-8 minutes (Python + deps + optional prompt)

#### Interactive Prompt
**WARNING:** Script asks: "Would you like to install par2cmdline-turbo? <y/N>"

**Mitigation:**
```bash
# Option 1: Pipe answer
echo "n" | pve-deploy ...

# Option 2: Default is 'N' so just press Enter
```

#### Network Configuration
- **Port:** 7777
- **Protocol:** HTTP
- **Listen Address:** 0.0.0.0

#### Post-Deployment Tasks
1. **Access:** http://192.168.10.xx:7777
2. **Initial Setup Wizard:**
   - Language selection
   - Usenet server configuration (provider details)
   - Download folders
3. **Configure Usenet Server:**
   - Host: (from provider)
   - Port: 563 (SSL) or 119 (plain)
   - Username/Password: (from provider)
   - Connections: 10-50 (check provider limits)
4. **Configure Folders:**
   - Temporary Download: /mnt/downloads/incomplete
   - Completed Download: /mnt/downloads/complete
5. **Categories:** TV, Movies, Music (auto-sort by *arr apps)
6. **API Key:** Generate and store in Vaultwarden

#### Usenet Provider Required
**SABnzbd is useless without a Usenet provider subscription:**
- Popular providers: Newshosting, Eweka, UsenetServer
- Typical cost: $5-15/month
- Alternative: Use qBittorrent only (free)

#### Dependencies & Integration
- **Dependencies:** Usenet provider subscription, network share
- **Used by:** Sonarr, Radarr, Lidarr, Readarr
- **Alternative to:** qBittorrent

---

## ARR Suite Deployment

### Deployment Order
```
1. Storage Setup (NFS/SMB shares)
   ↓
2. Prowlarr (indexer manager)
   ↓
3. qBittorrent OR SABnzbd (download client)
   ↓
4. Parallel deployment:
   - Sonarr (TV)
   - Radarr (Movies)
   - Lidarr (Music)
   - Readarr (Books)
   ↓
5. Bazarr (subtitles) - after Sonarr/Radarr
   ↓
6. Overseerr (requests) - after all *arr apps
```

### Resource Summary (ARR Suite)

| Service | CPU | RAM | Disk | Port | Notes |
|---------|-----|-----|------|------|-------|
| Prowlarr | 2 | 1GB | 4GB | 9696 | Deploy first |
| Sonarr | 2 | 1GB | 4GB | 8989 | After Prowlarr |
| Radarr | 2 | 1GB | 4GB | 7878 | After Prowlarr |
| Lidarr | 2 | 1GB | 4GB | 8686 | After Prowlarr |
| Readarr | 2 | 1GB | 4GB | 8787 | After Prowlarr |
| Bazarr | 2 | 1GB | 4GB | 6767 | After Sonarr/Radarr |
| Overseerr | 2 | 4GB → 2GB | 8GB | 5055 | Reduce RAM after build |
| qBittorrent | 2 | 2GB | 8GB | 8090 | Choose one |
| SABnzbd | 2 | 2GB | 5GB | 7777 | Choose one |

**Total (with qBittorrent):** 16 CPU, 13GB RAM, 41GB disk  
**Total (with SABnzbd):** 16 CPU, 13GB RAM, 38GB disk

**CPU Oversubscription:** 16 cores on 4 physical (400%) - **ACCEPTABLE**
- Media apps are I/O bound, not CPU bound
- Download client is most CPU intensive (during extraction)
- *arr apps mostly idle (periodic searches)

### Storage Architecture

#### Critical: Network Shares Required
All ARR services need access to shared storage:

```
/mnt/media/           # Main media library
├── tv/               # Sonarr
├── movies/           # Radarr
├── music/            # Lidarr
├── books/            # Readarr
└── audiobooks/       # Readarr

/mnt/downloads/       # Download client working directory
├── incomplete/       # In-progress downloads
├── complete/         # Finished downloads
└── torrents/         # Torrent files
```

#### Mount Options
**NFS (recommended for Linux):**
```bash
# In each container /etc/fstab
192.168.10.10:/mnt/pool/media    /mnt/media      nfs    defaults,_netdev  0  0
192.168.10.10:/mnt/pool/downloads /mnt/downloads nfs    defaults,_netdev  0  0
```

**SMB (if using Windows server):**
```bash
//192.168.10.10/media     /mnt/media      cifs   credentials=/root/.smbcreds,uid=0,gid=0  0  0
//192.168.10.10/downloads /mnt/downloads  cifs   credentials=/root/.smbcreds,uid=0,gid=0  0  0
```

#### Permission Requirements
- **Containers run as root** (unprivileged)
- **Network share must allow write access**
- **Folder permissions:** 775 or 777 on NFS export

### Integration Workflow

#### 1. Prowlarr → *arr Apps
```
1. Add indexers to Prowlarr
2. Prowlarr auto-syncs to Sonarr, Radarr, etc.
3. No need to configure indexers in each *arr app
```

#### 2. *arr Apps → Download Client
```
1. Configure qBittorrent in each *arr app:
   - Host: 192.168.10.xx
   - Port: 8090
   - Username: admin
   - Password: (changed from default)
   - Category: tv, movies, music, books
2. *arr app sends .torrent to qBittorrent
3. qBittorrent downloads to /mnt/downloads/complete/{category}
4. *arr app monitors completion and imports to /mnt/media/{category}
```

#### 3. Sonarr/Radarr → Bazarr
```
1. Bazarr connects to Sonarr/Radarr via API
2. Reads their databases for media list
3. Downloads subtitles to /mnt/media/tv/ or /mnt/media/movies/
4. Automatic subtitle matching
```

#### 4. Users → Overseerr → *arr Apps
```
1. User requests movie/show in Overseerr
2. Overseerr sends to Radarr/Sonarr via API
3. Radarr/Sonarr searches via Prowlarr
4. Download starts in qBittorrent
5. User gets notification when available
```

### Common Issues

#### Issue: *arr app can't see files downloaded by qBittorrent
**Symptoms:** Import fails, "No files found"

**Solution:** Path mapping mismatch
```bash
# qBittorrent sees: /mnt/downloads/complete/tv/Show.S01E01.mkv
# Sonarr must see same path: /mnt/downloads/complete/tv/Show.S01E01.mkv

# If paths differ, configure Remote Path Mapping in Sonarr:
# Settings → Download Clients → Remote Path Mappings
```

#### Issue: Prowlarr indexers won't sync to Sonarr/Radarr
**Symptoms:** Indexers don't appear in Sonarr

**Solution:** Check API connectivity
```bash
# In Prowlarr: Settings → Apps → Test
# Verify Sonarr URL and API key are correct
# Check firewall between containers
pct exec <prowlarr-ct> -- curl http://192.168.10.xx:8989/api/v3/system/status -H "X-Api-Key: <key>"
```

#### Issue: Downloads are slow or stalled
**Symptoms:** Torrents stuck at 0%, Usenet downloads fail

**Solution - Torrents:**
```bash
# Check qBittorrent logs
pct exec <qbit-ct> -- journalctl -u qbittorrent-nox -n 50

# Common issues:
# - No incoming connections (port forwarding needed)
# - No seeds available (try different indexer)
# - Disk full on download share
```

**Solution - Usenet:**
```bash
# Check SABnzbd logs
pct exec <sab-ct> -- journalctl -u sabnzbd -n 50

# Common issues:
# - Usenet provider down
# - Connection limit exceeded
# - Incomplete NZB files (need block account)
```

#### Issue: Permission denied when writing to network share
**Symptoms:** Import fails with permission error

**Solution:** Fix NFS export permissions
```bash
# On NFS server:
chmod 777 /mnt/pool/media
chmod 777 /mnt/pool/downloads

# Or configure NFS export with no_root_squash:
/mnt/pool/media 192.168.10.0/24(rw,sync,no_subtree_check,no_root_squash)
```

### Security Considerations

#### Download Client Isolation
- **qBittorrent/SABnzbd should NOT be internet-accessible**
- **Only *arr apps need API access**
- **Use VPN container if torrenting copyrighted content**

#### API Key Management
- **Store all API keys in Vaultwarden**
- **Regenerate if exposed**
- **Each *arr app has unique key**

#### Network Architecture
**Current (Staging):**
- All services on 192.168.10.0/16
- Direct access from management network

**Future (Production):**
- ARR apps: VLAN 100 (backend services)
- Overseerr: VLAN 40 (DMZ, user-facing)
- Reverse proxy routes external requests to Overseerr only
- *arr apps never exposed to frontend

---

**End of Analysis**
