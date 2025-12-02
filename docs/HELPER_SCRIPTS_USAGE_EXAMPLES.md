# Helper Scripts - Usage Examples (Man Pages)

**Purpose:** This document provides man-page style usage examples for deploying services using community helper scripts.

## Table of Contents
- [General Usage](#general-usage)
- [PostgreSQL](#postgresql-database-server)
- [Vaultwarden](#vaultwarden-password-manager)
- [Gitea](#gitea-git-service)
- [Wiki.js](#wikijs-documentation-platform)
- [Prowlarr](#prowlarr-indexer-manager)
- [Sonarr](#sonarr-tv-shows)
- [Radarr](#radarr-movies)
- [Lidarr](#lidarr-music)
- [Readarr](#readarr-books)
- [Bazarr](#bazarr-subtitles)
- [Overseerr](#overseerr-request-management)
- [qBittorrent](#qbittorrent-torrent-client)
- [SABnzbd](#sabnzbd-usenet-client)

---

## General Usage

### Syntax

```
pve-deploy <config-file>

OR

bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/<script>.sh)"
```

### Description

Community helper scripts automate LXC container creation and service installation on Proxmox VE. Scripts can run interactively (prompting for values) or non-interactively (using environment variables or config files).

### Options (Environment Variables)

All scripts accept these environment variables:

```bash
var_ctid          Container ID (auto-assigned if empty)
var_hostname      Hostname for the container
var_cpu           Number of CPU cores
var_ram           RAM in MB
var_disk          Disk size in GB
var_storage       Storage location (default: local-lvm)
var_os            Operating system (debian, ubuntu, alpine)
var_version       OS version
var_unprivileged  1=unprivileged (default), 0=privileged
var_brg           Bridge interface (default: vmbr0)
var_net           Network config: "dhcp" OR "ip=x.x.x.x/xx,gw=x.x.x.x"
var_gateway       Gateway IP (when using static IP)
var_vlan          VLAN tag (optional)
var_mac           MAC address (optional)
var_ssh           Enable SSH (default: yes)
var_pw            Root password (auto-generated if empty)
var_verbose       Verbose output (default: no)
var_tags          Semicolon-separated tags (e.g., "arr;media")
```

### Examples

**Interactive Mode:**
```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/prowlarr.sh)"
# Script will prompt for values
```

**Non-Interactive with Environment Variables:**
```bash
export var_ctid="200"
export var_hostname="prowlarr"
export var_cpu="2"
export var_ram="1024"
export var_disk="4"
export var_net="ip=192.168.10.30/16,gw=192.168.10.1"
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/prowlarr.sh)"
```

**Using Config File with pve-deploy:**
```bash
cat > prowlarr.conf <<EOF
var_ctid="200"
var_hostname="prowlarr"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_net="ip=192.168.10.30/16,gw=192.168.10.1"
var_tags="arr;indexer"
EOF

pve-deploy prowlarr.conf
```

### Updating Existing Container

All scripts include an update function:

```bash
pct exec <ctid> -- bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/<script>.sh)" -- update
```

---

## PostgreSQL (Database Server)

### Name
postgresql.sh - Deploy PostgreSQL database server in LXC container

### Synopsis
```bash
pve-deploy postgresql.conf
```

### Description
Creates an unprivileged LXC container running PostgreSQL database server. Supports PostgreSQL versions 15, 16, 17, or 18. Optionally installs Adminer web interface.

**Default Resources:** 1 CPU, 1GB RAM, 4GB disk

### Configuration Example

```bash
cat > /tmp/hx310-db-postgresql.conf <<'EOF'
var_ctid="100"
var_hostname="hx310-db-postgresql"
var_cpu="2"
var_ram="8192"
var_disk="100"
var_net="ip=192.168.10.20/16,gw=192.168.10.1"
var_tags="database;hx310;phase3"
var_storage="local-lvm"
EOF

pve-deploy /tmp/hx310-db-postgresql.conf
```

### Post-Deployment

The install script will interactively prompt for:
1. **PostgreSQL version:** 15, 16, 17, or 18
2. **Adminer installation:** y/N

**To provide answers non-interactively:**
```bash
# Option 1: Pipe answers
echo -e "18\nn" | pve-deploy postgresql.conf

# Option 2: Expect script (more reliable)
expect <<EOF
spawn pve-deploy postgresql.conf
expect "Select PostgreSQL version*"
send "18\r"
expect "Install Adminer*"
send "n\r"
expect eof
EOF
```

### Security Hardening

```bash
# Restrict pg_hba.conf to backend VLANs only
pct exec 100 -- bash <<'SECURE'
PG_VER=$(ls /etc/postgresql/ | head -1)
cat > /etc/postgresql/${PG_VER}/main/pg_hba.conf <<HBACONF
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     peer
host    all             all             10.10.110.0/24          scram-sha-256
host    all             all             10.10.100.0/24          scram-sha-256
host    all             all             10.10.200.0/24          scram-sha-256
host    all             all             0.0.0.0/0               reject
HBACONF
systemctl restart postgresql
SECURE
```

### Database Creation

```bash
pct exec 100 -- su - postgres -c "psql" <<'SQL'
CREATE DATABASE vaultwarden;
CREATE USER vaultwarden WITH ENCRYPTED PASSWORD 'secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE vaultwarden TO vaultwarden;

CREATE DATABASE gitea;
CREATE USER gitea WITH ENCRYPTED PASSWORD 'secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE gitea TO gitea;

CREATE DATABASE wikijs;
CREATE USER wikijs WITH ENCRYPTED PASSWORD 'secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE wikijs TO wikijs;
SQL
```

### Files
- **Script:** community-scripts/ct/postgresql.sh
- **Install:** community-scripts/install/postgresql-install.sh
- **Data:** /var/lib/postgresql/
- **Config:** /etc/postgresql/<version>/main/
- **Service:** postgresql.service

### See Also
vaultwarden(8), gitea(8), wikijs(8)

---

## Vaultwarden (Password Manager)

### Name
vaultwarden.sh - Deploy Vaultwarden password manager in LXC container

### Synopsis
```bash
pve-deploy vaultwarden.conf
```

### Description
Creates an unprivileged LXC container that compiles and runs Vaultwarden (Bitwarden-compatible password manager). Compilation requires 20-30 minutes and high resources (4 CPU, 6GB RAM). After deployment, resources can be reduced.

**Default Resources:** 4 CPU, 6GB RAM, 20GB disk  
**Recommended After Build:** 1 CPU, 2GB RAM

### Configuration Example

```bash
cat > /tmp/hx310-db-vaultwarden.conf <<'EOF'
var_ctid="101"
var_hostname="hx310-db-vaultwarden"
var_cpu="4"
var_ram="6144"
var_disk="20"
var_net="ip=192.168.10.21/16,gw=192.168.10.1"
var_tags="security;password;hx310;phase3"
EOF

pve-deploy /tmp/hx310-db-vaultwarden.conf

# After installation completes, reduce resources
pct set 101 -cores 1 -memory 2048
pct reboot 101
```

### Post-Deployment

**1. Access web interface:**
```
https://192.168.10.21:8000
```

**2. Create admin account** (first user)

**3. Generate and set ADMIN_TOKEN:**
```bash
# Generate random token
TOKEN=$(openssl rand -base64 32)
echo "Save this token: $TOKEN"

# Hash with Argon2
HASHED=$(echo -n "$TOKEN" | argon2 "$(openssl rand -base64 32)" -t 2 -m 16 -p 4 -l 64 -e)

# Set in config
pct exec 101 -- bash <<EOF
sed -i "s|^ADMIN_TOKEN=.*|ADMIN_TOKEN='${HASHED}'|" /opt/vaultwarden/.env
systemctl restart vaultwarden
EOF

echo "Admin panel: https://192.168.10.21:8000/admin"
```

**4. Disable public signups:**
```bash
pct exec 101 -- bash <<EOF
sed -i "s|^# SIGNUPS_ALLOWED=.*|SIGNUPS_ALLOWED=false|" /opt/vaultwarden/.env
systemctl restart vaultwarden
EOF
```

**5. Configure PostgreSQL database** (optional, recommended):
```bash
pct exec 101 -- bash <<EOF
sed -i "s|^# DATABASE_URL=.*|DATABASE_URL=postgresql://vaultwarden:password@192.168.10.20:5432/vaultwarden|" /opt/vaultwarden/.env
systemctl restart vaultwarden
EOF
```

### Files
- **Script:** community-scripts/ct/vaultwarden.sh
- **Binary:** /opt/vaultwarden/bin/vaultwarden
- **Config:** /opt/vaultwarden/.env
- **Data:** /opt/vaultwarden/data/
- **Service:** vaultwarden.service

### See Also
postgresql(8)

---

## Gitea (Git Service)

### Name
gitea.sh - Deploy Gitea self-hosted Git service in LXC container

### Synopsis
```bash
pve-deploy gitea.conf
```

### Description
Creates an unprivileged LXC container running Gitea, a lightweight self-hosted Git service. Ideal for mirroring GitHub repositories locally.

**Default Resources:** 1 CPU, 1GB RAM, 8GB disk  
**Recommended:** Increase disk to 50GB for repository storage

### Configuration Example

```bash
cat > /tmp/hx310-db-gitea.conf <<'EOF'
var_ctid="102"
var_hostname="hx310-db-gitea"
var_cpu="1"
var_ram="2048"
var_disk="50"
var_net="ip=192.168.10.22/16,gw=192.168.10.1"
var_tags="git;scm;hx310;phase3"
EOF

pve-deploy /tmp/hx310-db-gitea.conf
```

### Post-Deployment

**1. Access setup wizard:**
```
http://192.168.10.22:3000
```

**2. Configure database:**
- Database Type: PostgreSQL
- Host: 192.168.10.20:5432
- Username: gitea
- Password: (from Vaultwarden)
- Database Name: gitea

**3. Configure general settings:**
- Site Title: Homelab Gitea
- Repository Root Path: /var/lib/gitea/data/repositories
- Git LFS Root Path: /var/lib/gitea/data/lfs
- Run As Username: gitea
- SSH Server Domain: 192.168.10.22
- SSH Port: 22
- HTTP Listen Port: 3000
- Application URL: http://192.168.10.22:3000/

**4. Create admin account** and store in Vaultwarden

**5. Mirror GitHub repository:**
- Click "+" → New Migration
- Source: GitHub
- Repository URL: https://github.com/username/repo
- Check "This repository will be a mirror"

### SSH Access

```bash
# Clone via SSH
git clone ssh://git@192.168.10.22:22/homelab/proxmox-homelab.git

# Add as remote
git remote add homelab ssh://git@192.168.10.22:22/homelab/proxmox-homelab.git

# Push to homelab
git push homelab main
```

### Files
- **Script:** community-scripts/ct/gitea.sh
- **Binary:** /usr/local/bin/gitea
- **Config:** /etc/gitea/app.ini
- **Data:** /var/lib/gitea/
- **Service:** gitea.service

### See Also
postgresql(8), wikijs(8)

---

## Wiki.js (Documentation Platform)

### Name
wikijs.sh - Deploy Wiki.js documentation platform in LXC container

### Synopsis
```bash
pve-deploy wikijs.conf
```

### Description
Creates an unprivileged LXC container running Wiki.js, a modern documentation platform with Git sync capabilities. Requires external database (PostgreSQL recommended).

**Default Resources:** 2 CPU, 2GB RAM, 10GB disk

**WARNING:** Wiki.js v3.x+ does NOT support SQLite. PostgreSQL required.

### Configuration Example

```bash
cat > /tmp/hx310-db-wikijs.conf <<'EOF'
var_ctid="103"
var_hostname="hx310-db-wikijs"
var_cpu="2"
var_ram="2048"
var_disk="20"
var_net="ip=192.168.10.23/16,gw=192.168.10.1"
var_tags="documentation;wiki;hx310;phase3"
EOF

pve-deploy /tmp/hx310-db-wikijs.conf
```

### Post-Deployment

**1. Access setup wizard:**
```
http://192.168.10.23:3000
```

**2. Configure database:**
- Database Type: PostgreSQL
- Host: 192.168.10.20
- Port: 5432
- Database: wikijs
- Username: wikijs
- Password: (from Vaultwarden)

**3. Configure site:**
- Site URL: http://192.168.10.23:3000
- Language: English
- Admin Email: admin@homelab.local
- Admin Password: (store in Vaultwarden)

**4. Configure Git sync:**
- Administration → Storage → Git
- Authentication Type: Basic
- Repository URL: http://192.168.10.22:3000/homelab/proxmox-homelab.git
- Branch: main
- Username: (Gitea username)
- Password: (Gitea password)
- Sync Direction: Pull only
- Sync Interval: 1 hour
- Local Repository Path: ./data/repo

**5. Trigger initial sync** and verify docs/ folder appears

### Git Sync Workflow

```
GitHub (SSoT)  →  Gitea (mirror)  →  Wiki.js (display)
    Manual           Hourly sync       Hourly pull
```

**Maximum delay:** 2 hours for changes to appear

### Files
- **Script:** community-scripts/ct/wikijs.sh
- **App:** /opt/wikijs/
- **Config:** /opt/wikijs/config.yml
- **Data:** /opt/wikijs/data/
- **Service:** wikijs.service

### See Also
postgresql(8), gitea(8)

---

## Prowlarr (Indexer Manager)

### Name
prowlarr.sh - Deploy Prowlarr indexer manager for *arr apps

### Synopsis
```bash
pve-deploy prowlarr.conf
```

### Description
Creates an unprivileged LXC container running Prowlarr, the centralized indexer manager for Sonarr, Radarr, Lidarr, and Readarr. Manages torrent trackers and Usenet indexers, syncing them to all *arr applications.

**Default Resources:** 2 CPU, 1GB RAM, 4GB disk

**Deploy First:** Prowlarr must be deployed before other *arr apps for indexer synchronization.

### Configuration Example

```bash
cat > /tmp/prowlarr.conf <<'EOF'
var_ctid="200"
var_hostname="prowlarr"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_net="ip=192.168.10.30/16,gw=192.168.10.1"
var_tags="arr;indexer"
EOF

pve-deploy /tmp/prowlarr.conf
```

### Post-Deployment

**1. Access:** http://192.168.10.30:9696

**2. Add indexers:**
- Settings → Indexers → Add Indexer
- Add public trackers (1337x, RARBG, etc.)
- Add private trackers (with credentials)
- Add Usenet indexers (requires account)

**3. Add applications:**
- Settings → Apps → Add Application
- Select: Sonarr, Radarr, Lidarr, Readarr
- Enter API URL and API key for each
- Test connection
- Prowlarr will auto-sync indexers to each app

**4. Test search:**
- Search tab
- Try searching for content
- Verify indexers are returning results

### Files
- **Script:** community-scripts/ct/prowlarr.sh
- **Binary:** /opt/Prowlarr/
- **Data:** /var/lib/prowlarr/
- **Service:** prowlarr.service
- **Port:** 9696

### See Also
sonarr(8), radarr(8), lidarr(8), readarr(8)

---

## Sonarr (TV Shows)

### Name
sonarr.sh - Deploy Sonarr TV show automation

### Synopsis
```bash
pve-deploy sonarr.conf
```

### Description
Creates an unprivileged LXC container running Sonarr v4, automated TV show management system. Monitors, downloads, and organizes TV episodes.

**Default Resources:** 2 CPU, 1GB RAM, 4GB disk

**Requires:** Network share for media storage, Prowlarr for indexers, qBittorrent/SABnzbd for downloads

### Configuration Example

```bash
cat > /tmp/sonarr.conf <<'EOF'
var_ctid="201"
var_hostname="sonarr"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_net="ip=192.168.10.31/16,gw=192.168.10.1"
var_tags="arr;tv;media"
EOF

pve-deploy /tmp/sonarr.conf

# Mount network shares
pct exec 201 -- bash <<'MOUNT'
echo "192.168.10.10:/mnt/pool/media /mnt/media nfs defaults,_netdev 0 0" >> /etc/fstab
echo "192.168.10.10:/mnt/pool/downloads /mnt/downloads nfs defaults,_netdev 0 0" >> /etc/fstab
mkdir -p /mnt/media /mnt/downloads
mount -a
MOUNT
```

### Post-Deployment

**1. Access:** http://192.168.10.31:8989

**2. Connect indexers:**
- Settings → Indexers → Add from Prowlarr
- Prowlarr automatically syncs configured indexers

**3. Connect download client:**
- Settings → Download Clients → Add → qBittorrent
- Host: 192.168.10.40
- Port: 8090
- Username: admin
- Password: (changed from default)
- Category: tv

**4. Add root folder:**
- Settings → Media Management → Root Folders
- Add: /mnt/media/tv

**5. Add TV shows:**
- Series → Add New
- Search for show or import existing library

**6. Configure quality:**
- Settings → Profiles
- Create/edit quality profiles (1080p, 4K, etc.)

### Update

```bash
pct exec 201 -- bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/sonarr.sh)" -- update
```

### Files
- **Script:** community-scripts/ct/sonarr.sh
- **Binary:** /opt/Sonarr/
- **Data:** /var/lib/sonarr/
- **Service:** sonarr.service
- **Port:** 8989

### See Also
prowlarr(8), radarr(8), qbittorrent(8), sabnzbd(8), bazarr(8), overseerr(8)

---

## Radarr (Movies)

### Name
radarr.sh - Deploy Radarr movie automation

### Synopsis
```bash
pve-deploy radarr.conf
```

### Description
Creates an unprivileged LXC container running Radarr, automated movie management system. Monitors, downloads, and organizes movies.

**Default Resources:** 2 CPU, 1GB RAM, 4GB disk

**Usage is identical to Sonarr**, but for movies instead of TV shows.

### Configuration Example

```bash
cat > /tmp/radarr.conf <<'EOF'
var_ctid="202"
var_hostname="radarr"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_net="ip=192.168.10.32/16,gw=192.168.10.1"
var_tags="arr;movies;media"
EOF

pve-deploy /tmp/radarr.conf

# Mount network shares (same as Sonarr)
pct exec 202 -- bash <<'MOUNT'
echo "192.168.10.10:/mnt/pool/media /mnt/media nfs defaults,_netdev 0 0" >> /etc/fstab
echo "192.168.10.10:/mnt/pool/downloads /mnt/downloads nfs defaults,_netdev 0 0" >> /etc/fstab
mkdir -p /mnt/media /mnt/downloads
mount -a
MOUNT
```

### Post-Deployment

Configuration is identical to Sonarr:

1. Access: http://192.168.10.32:7878
2. Connect Prowlarr for indexers
3. Connect qBittorrent/SABnzbd (category: movies)
4. Add root folder: /mnt/media/movies
5. Add movies
6. Configure quality profiles

### Files
- **Script:** community-scripts/ct/radarr.sh
- **Binary:** /opt/Radarr/
- **Data:** /var/lib/radarr/
- **Service:** radarr.service
- **Port:** 7878

### See Also
sonarr(8), prowlarr(8), qbittorrent(8), bazarr(8), overseerr(8)

---

## Lidarr (Music)

### Name
lidarr.sh - Deploy Lidarr music automation

### Synopsis
```bash
pve-deploy lidarr.conf
```

### Description
Creates an unprivileged LXC container running Lidarr, automated music management system. Monitors, downloads, and organizes music albums.

**Default Resources:** 2 CPU, 1GB RAM, 4GB disk

**Additional Dependencies:** libchromaprint-tools, mediainfo (auto-installed)

### Configuration Example

```bash
cat > /tmp/lidarr.conf <<'EOF'
var_ctid="203"
var_hostname="lidarr"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_net="ip=192.168.10.33/16,gw=192.168.10.1"
var_tags="arr;music;media"
EOF

pve-deploy /tmp/lidarr.conf

# Mount shares
pct exec 203 -- bash <<'MOUNT'
echo "192.168.10.10:/mnt/pool/media /mnt/media nfs defaults,_netdev 0 0" >> /etc/fstab
echo "192.168.10.10:/mnt/pool/downloads /mnt/downloads nfs defaults,_netdev 0 0" >> /etc/fstab
mkdir -p /mnt/media /mnt/downloads
mount -a
MOUNT
```

### Post-Deployment

1. Access: http://192.168.10.33:8686
2. Connect Prowlarr
3. Connect qBittorrent/SABnzbd (category: music)
4. Add root folder: /mnt/media/music
5. Configure MusicBrainz for metadata
6. Add artists/albums

### Files
- **Script:** community-scripts/ct/lidarr.sh
- **Binary:** /opt/Lidarr/
- **Data:** /var/lib/lidarr/
- **Service:** lidarr.service
- **Port:** 8686

### See Also
sonarr(8), radarr(8), prowlarr(8), qbittorrent(8)

---

## Readarr (Books)

### Name
readarr.sh - Deploy Readarr book/audiobook automation

### Synopsis
```bash
pve-deploy readarr.conf
```

### Description
Creates an unprivileged LXC container running Readarr, automated book and audiobook management system.

**Default Resources:** 2 CPU, 1GB RAM, 4GB disk

### Configuration Example

```bash
cat > /tmp/readarr.conf <<'EOF'
var_ctid="204"
var_hostname="readarr"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_net="ip=192.168.10.34/16,gw=192.168.10.1"
var_tags="arr;books;media"
EOF

pve-deploy /tmp/readarr.conf

# Mount shares
pct exec 204 -- bash <<'MOUNT'
echo "192.168.10.10:/mnt/pool/media /mnt/media nfs defaults,_netdev 0 0" >> /etc/fstab
echo "192.168.10.10:/mnt/pool/downloads /mnt/downloads nfs defaults,_netdev 0 0" >> /etc/fstab
mkdir -p /mnt/media /mnt/downloads
mount -a
MOUNT
```

### Post-Deployment

1. Access: http://192.168.10.34:8787
2. Connect Prowlarr
3. Connect qBittorrent/SABnzbd (category: books)
4. Add root folders: /mnt/media/books, /mnt/media/audiobooks
5. Configure Goodreads/Calibre for metadata
6. Add authors/books

### Files
- **Script:** community-scripts/ct/readarr.sh
- **Binary:** /opt/Readarr/
- **Data:** /var/lib/readarr/
- **Service:** readarr.service
- **Port:** 8787

### See Also
sonarr(8), radarr(8), lidarr(8), prowlarr(8)

---

## Bazarr (Subtitles)

### Name
bazarr.sh - Deploy Bazarr subtitle automation

### Synopsis
```bash
pve-deploy bazarr.conf
```

### Description
Creates an unprivileged LXC container running Bazarr, automated subtitle management for Sonarr and Radarr content. Uses Python 3.12 virtual environment.

**Default Resources:** 2 CPU, 1GB RAM, 4GB disk

**Requires:** Sonarr and/or Radarr, same network share access

### Configuration Example

```bash
cat > /tmp/bazarr.conf <<'EOF'
var_ctid="205"
var_hostname="bazarr"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_net="ip=192.168.10.35/16,gw=192.168.10.1"
var_tags="arr;subtitles;media"
EOF

pve-deploy /tmp/bazarr.conf

# Mount media share (needs same paths as Sonarr/Radarr)
pct exec 205 -- bash <<'MOUNT'
echo "192.168.10.10:/mnt/pool/media /mnt/media nfs defaults,_netdev 0 0" >> /etc/fstab
mkdir -p /mnt/media
mount -a
MOUNT
```

### Post-Deployment

**1. Access:** http://192.168.10.35:6767

**2. Connect Sonarr:**
- Settings → Sonarr
- Address: http://192.168.10.31:8989
- API Key: (from Sonarr)
- Test and Save

**3. Connect Radarr:**
- Settings → Radarr
- Address: http://192.168.10.32:7878
- API Key: (from Radarr)
- Test and Save

**4. Add subtitle providers:**
- Settings → Providers
- Add: OpenSubtitles, Subscene, etc.
- Configure API keys if needed

**5. Configure languages:**
- Settings → Languages
- Add preferred subtitle languages

**6. Configure sync:**
- Settings → Scheduler
- Set sync interval (e.g., 6 hours)

### Path Mappings

If Bazarr and *arr apps see storage differently, configure:
- Settings → Sonarr/Radarr → Path Mappings
- Example: `/media` (in arr app) → `/mnt/media` (in Bazarr)

### Files
- **Script:** community-scripts/ct/bazarr.sh
- **App:** /opt/bazarr/
- **Venv:** /opt/bazarr/venv/
- **Data:** /var/lib/bazarr/
- **Service:** bazarr.service
- **Port:** 6767

### See Also
sonarr(8), radarr(8)

---

## Overseerr (Request Management)

### Name
overseerr.sh - Deploy Overseerr media request platform

### Synopsis
```bash
pve-deploy overseerr.conf
```

### Description
Creates an unprivileged LXC container running Overseerr, a media request and discovery platform for Plex/Jellyfin users. Automatically forwards requests to Sonarr/Radarr.

**Default Resources:** 2 CPU, 4GB RAM, 8GB disk

**WARNING:** Node.js build requires 4GB RAM (~10-15 minutes). Reduce to 2GB after deployment.

### Configuration Example

```bash
cat > /tmp/overseerr.conf <<'EOF'
var_ctid="206"
var_hostname="overseerr"
var_cpu="2"
var_ram="4096"
var_disk="8"
var_net="ip=192.168.10.36/16,gw=192.168.10.1"
var_tags="arr;requests;media;frontend"
EOF

pve-deploy /tmp/overseerr.conf

# Wait for build to complete (~15 minutes)
# Then reduce RAM
pct set 206 -memory 2048
pct reboot 206
```

### Post-Deployment

**1. Access:** http://192.168.10.36:5055

**2. Initial setup wizard:**

**Step 1: Plex/Jellyfin:**
- Connect to Plex or Jellyfin for user authentication
- This enables single sign-on for users

**Step 2: Sonarr:**
- Server: http://192.168.10.31:8989
- API Key: (from Sonarr)
- Default Quality Profile: (select)
- Root Folder: /mnt/media/tv

**Step 3: Radarr:**
- Server: http://192.168.10.32:7878
- API Key: (from Radarr)
- Default Quality Profile: (select)
- Root Folder: /mnt/media/movies

**3. Configure request rules:**
- Settings → Users → Default Permissions
- Set auto-approval for certain users/groups
- Set request limits (e.g., 10 per week)

**4. Configure notifications:**
- Settings → Notifications
- Add Discord, Slack, email, etc.
- Notify users when requests are available

**5. User access:**
- Give users the URL: http://192.168.10.36:5055
- They sign in with Plex/Jellyfin credentials
- Users can search and request content

### Files
- **Script:** community-scripts/ct/overseerr.sh
- **App:** /opt/overseerr/
- **Config:** /opt/overseerr/config/
- **Service:** overseerr.service
- **Port:** 5055

### See Also
sonarr(8), radarr(8), plex(8), jellyfin(8)

---

## qBittorrent (Torrent Client)

### Name
qbittorrent.sh - Deploy qBittorrent torrent client

### Synopsis
```bash
pve-deploy qbittorrent.conf
```

### Description
Creates an unprivileged LXC container running qBittorrent-nox (headless BitTorrent client). Used by all *arr applications for torrent downloads.

**Default Resources:** 2 CPU, 2GB RAM, 8GB disk

**Default Credentials:** admin / adminadmin (**CHANGE IMMEDIATELY**)

### Configuration Example

```bash
cat > /tmp/qbittorrent.conf <<'EOF'
var_ctid="210"
var_hostname="qbittorrent"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_net="ip=192.168.10.40/16,gw=192.168.10.1"
var_tags="arr;torrent;download"
EOF

pve-deploy /tmp/qbittorrent.conf

# Mount downloads share
pct exec 210 -- bash <<'MOUNT'
echo "192.168.10.10:/mnt/pool/downloads /mnt/downloads nfs defaults,_netdev 0 0" >> /etc/fstab
mkdir -p /mnt/downloads
mount -a
MOUNT
```

### Post-Deployment

**1. Access:** http://192.168.10.40:8090

**2. Login:** admin / adminadmin

**3. CHANGE PASSWORD IMMEDIATELY:**
- Tools → Options → Web UI
- Change password
- Save and re-login

**4. Configure paths:**
- Options → Downloads
- Default Save Path: /mnt/downloads/complete
- Temp Path: /mnt/downloads/incomplete
- Enable "Create subfolder for torrents with multiple files"

**5. Configure connection:**
- Options → Connection
- Port used for incoming connections: 6881 (or random)
- Disable UPnP/NAT-PMP (firewall handles it)

**6. Configure categories:**
- Right-click in categories pane
- Add: tv, movies, music, books
- Set save paths: /mnt/downloads/complete/tv, etc.

**7. Store credentials in Vaultwarden**

### Usage in *arr Apps

In each *arr app:
- Settings → Download Clients → Add → qBittorrent
- Host: 192.168.10.40
- Port: 8090
- Username: admin
- Password: (changed password)
- Category: tv (or movies, music, books)
- Test → Save

### Files
- **Script:** community-scripts/ct/qbittorrent.sh
- **Binary:** /opt/qbittorrent/qbittorrent-nox
- **Config:** ~/.config/qBittorrent/
- **Service:** qbittorrent-nox.service
- **Port:** 8090 (Web UI)

### See Also
sonarr(8), radarr(8), lidarr(8), readarr(8), sabnzbd(8)

---

## SABnzbd (Usenet Client)

### Name
sabnzbd.sh - Deploy SABnzbd Usenet downloader

### Synopsis
```bash
pve-deploy sabnzbd.conf
```

### Description
Creates an unprivileged LXC container running SABnzbd, a Usenet (NZB) downloader. Alternative to torrents, requires Usenet provider subscription.

**Default Resources:** 2 CPU, 2GB RAM, 5GB disk

**Interactive Prompt:** Asks about par2cmdline-turbo installation (default: N)

**Requires:** Usenet provider subscription ($5-15/month)

### Configuration Example

```bash
cat > /tmp/sabnzbd.conf <<'EOF'
var_ctid="211"
var_hostname="sabnzbd"
var_cpu="2"
var_ram="2048"
var_disk="5"
var_net="ip=192.168.10.41/16,gw=192.168.10.1"
var_tags="arr;usenet;download"
EOF

# Answer "n" to par2cmdline-turbo prompt
echo "n" | pve-deploy /tmp/sabnzbd.conf

# Mount downloads share
pct exec 211 -- bash <<'MOUNT'
echo "192.168.10.10:/mnt/pool/downloads /mnt/downloads nfs defaults,_netdev 0 0" >> /etc/fstab
mkdir -p /mnt/downloads
mount -a
MOUNT
```

### Post-Deployment

**1. Access:** http://192.168.10.41:7777

**2. Initial setup wizard:**

**Step 1: Language** - Select language

**Step 2: Usenet Server:**
- Host: (from provider, e.g., news.usenetserver.com)
- Port: 563 (SSL) or 119 (plain)
- Username: (from provider)
- Password: (from provider)
- Connections: 10-50 (check provider limits)
- SSL: Yes (recommended)
- Test Server → Next

**Step 3: Folders:**
- Temporary Download Folder: /mnt/downloads/incomplete
- Completed Download Folder: /mnt/downloads/complete

**3. Configure categories:**
- Config → Categories
- Add: tv, movies, music, books
- Set folder for each: /mnt/downloads/complete/tv, etc.

**4. Get API key:**
- Config → General → SABnzbd API Key
- Copy API key

**5. Store credentials in Vaultwarden**

### Usage in *arr Apps

In each *arr app:
- Settings → Download Clients → Add → SABnzbd
- Host: 192.168.10.41
- Port: 7777
- API Key: (from SABnzbd)
- Category: tv (or movies, music, books)
- Test → Save

### Usenet Providers

Popular providers:
- **Newshosting:** ~$10/month, fast, reliable
- **Eweka:** ~$8/month, good retention
- **UsenetServer:** ~$8/month, US-based

**Tip:** Some *arr users have both a primary provider and a "block account" (pay-per-GB) for missing articles.

### Files
- **Script:** community-scripts/ct/sabnzbd.sh
- **App:** /opt/sabnzbd/
- **Venv:** /opt/sabnzbd/venv/
- **Service:** sabnzbd.service
- **Port:** 7777

### See Also
sonarr(8), radarr(8), lidarr(8), readarr(8), qbittorrent(8)

---

## End of Manual Pages
