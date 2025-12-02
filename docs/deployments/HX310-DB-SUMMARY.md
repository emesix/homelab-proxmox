# HX310-DB (breintrein) Core Services Deployment Summary

**Node:** pve-hx310-db (192.168.10.12)  
**Deployment Date:** 2025-11-30  
**Status:** ✅ COMPLETE - All 4 core services deployed and operational

---

## Deployed Services Overview

| CT ID | Service | IP | Ports | CPU | RAM | Storage | Status |
|-------|---------|----|----|-----|-----|---------|--------|
| 101 | PostgreSQL | 192.168.10.20 | 5432 | 2 | 8GB | 100GB NVMe | ✅ Running |
| 102 | Vaultwarden | 192.168.10.21 | 80, 443 | 1 | 2GB | 20GB NVMe | ✅ Running |
| 103 | Gitea | 192.168.10.22 | 3000, 22 | 1 | 2GB | 50GB SATA | ✅ Running |
| 104 | Wiki.js | 192.168.10.23 | 80 | 1 | 2GB | 20GB NVMe | ✅ Running |

---

## Service Details

### CT101 - PostgreSQL Database Server
- **Purpose:** Central database for all services
- **Version:** PostgreSQL 15.14
- **Databases:**
  - `vaultwarden` (for password manager)
  - `gitea` (for Git server)
  - `wikijs` (for documentation platform)
- **Storage:** ZFS dataset `rpool/postgres` on NVMe (optimized: recordsize=16K, lz4 compression)
- **Performance:** Tuned for 8GB RAM, ZFS/SSD workload
- **Access:** Remote access enabled for 192.168.10.0/16
- **Documentation:** [postgresql-ct101.md](postgresql-ct101.md)

### CT102 - Vaultwarden Password Manager
- **Purpose:** Secure credential storage for homelab
- **Version:** Latest (Docker image)
- **Web UI:** http://192.168.10.21
- **Admin Panel:** http://192.168.10.21/admin
- **Backend:** PostgreSQL on CT101
- **Storage:** ZFS dataset `rpool/vaultwarden` on NVMe
- **Features:**
  - Bitwarden-compatible API
  - Browser extensions supported
  - Mobile apps compatible
  - Admin panel enabled
- **Documentation:** [vaultwarden-ct102.md](vaultwarden-ct102.md)

### CT103 - Gitea Git Server
- **Purpose:** Local Git repository hosting and GitHub mirror
- **Version:** 1.25.2
- **Web UI:** http://192.168.10.22:3000
- **SSH:** git@192.168.10.22:22
- **Backend:** PostgreSQL on CT101
- **Repository Storage:** ZFS dataset `datastore/gitea` on SATA SSD
- **Features:**
  - Git repository hosting
  - GitHub repository mirroring
  - SSH and HTTP(S) access
  - Web-based Git management
  - LFS support enabled
- **Container Type:** Unprivileged LXC (better security)
- **Documentation:** [gitea-ct103.md](gitea-ct103.md)

### CT104 - Wiki.js Documentation Platform
- **Purpose:** Documentation and knowledge base
- **Version:** 2.x (latest Docker image)
- **Web UI:** http://192.168.10.23
- **Backend:** PostgreSQL on CT101
- **Features:**
  - Markdown editing
  - Git sync with Gitea
  - Search functionality
  - Access control
  - Rich media support
- **Documentation:** [wikijs-ct104.md](wikijs-ct104.md)

---

## Resource Utilization

### CPU Allocation
- **Total Allocated:** 5 cores (oversubscribed on 4-core CPU)
- **Distribution:**
  - PostgreSQL: 2 cores (50%)
  - Vaultwarden: 1 core (25%)
  - Gitea: 1 core (25%)
  - Wiki.js: 1 core (25%)
- **Note:** Oversubscription acceptable - services won't peak simultaneously

### Memory Allocation
- **Total Allocated:** 14GB / 32GB available (44%)
- **Distribution:**
  - PostgreSQL: 8GB
  - Vaultwarden: 2GB
  - Gitea: 2GB
  - Wiki.js: 2GB
- **Available:** 18GB for host and future services

### Storage Allocation

**NVMe Storage (rpool - 928GB):**
- System: ~50GB
- PostgreSQL data: 100GB (actual: ~500MB)
- Vaultwarden data: 20GB (actual: ~200MB)
- Wiki.js: 20GB (actual: ~100MB)
- **Total Used:** ~70GB
- **Available:** ~858GB

**SATA SSD Storage (datastore - 954GB):**
- Gitea repositories: 50GB (actual: ~1GB)
- Backups: Reserved
- **Total Used:** ~1GB
- **Available:** ~953GB

---

## Network Configuration

All services on VLAN 192.168.10.0/16 (staging network):
- **Gateway:** 192.168.10.1
- **DNS:** 8.8.8.8
- **Bridge:** vmbr0

| Service | IP | Ports |
|---------|-------|-------|
| PostgreSQL | 192.168.10.20 | 5432 |
| Vaultwarden | 192.168.10.21 | 80, 443 |
| Gitea | 192.168.10.22 | 3000 (HTTP), 22 (SSH) |
| Wiki.js | 192.168.10.23 | 80 |

---

## Access Information

### Web Interfaces
- **Vaultwarden:** http://192.168.10.21
- **Vaultwarden Admin:** http://192.168.10.21/admin
- **Gitea:** http://192.168.10.22:3000
- **Wiki.js:** http://192.168.10.23

### SSH Access
- **PostgreSQL CT:** `ssh root@192.168.10.20` (password: NikonD90)
- **Vaultwarden CT:** `ssh root@192.168.10.21` (password: NikonD90)
- **Gitea CT:** `ssh root@192.168.10.22` (password: NikonD90)
- **Wiki.js CT:** `ssh root@192.168.10.23` (password: NikonD90)
- **Git SSH:** `git clone ssh://git@192.168.10.22/repo.git`

### Database Access
```bash
# From workstation or any node
PGPASSWORD=$(cat /tmp/pw1) psql -h 192.168.10.20 -U vaultwarden -d vaultwarden
PGPASSWORD=$(cat /tmp/pw2) psql -h 192.168.10.20 -U gitea -d gitea
PGPASSWORD=$(cat /tmp/pw3) psql -h 192.168.10.20 -U wikijs -d wikijs
```

---

## Credentials to Store in Vaultwarden

**IMPORTANT:** Complete initial setup and store these credentials immediately.

See [CREDENTIALS-TO-STORE.md](CREDENTIALS-TO-STORE.md) for complete list:
- PostgreSQL passwords (3 databases) - `/tmp/pw1`, `/tmp/pw2`, `/tmp/pw3`
- Vaultwarden admin token - `/tmp/vaultwarden-admin-token`
- LXC container root passwords (staging: NikonD90)
- Gitea admin account
- Wiki.js admin account

---

## Initial Setup Checklist

### 1. Vaultwarden Setup
- [ ] Access http://192.168.10.21
- [ ] Create admin account
- [ ] Store all credentials from CREDENTIALS-TO-STORE.md
- [ ] Disable public signups
- [ ] Export vault as backup

### 2. Gitea Setup
- [ ] Access http://192.168.10.22:3000
- [ ] Complete installation wizard
- [ ] Create admin account (store in Vaultwarden)
- [ ] Add SSH key
- [ ] Mirror GitHub repository: emesix/homelab-proxmox
- [ ] Disable registration

### 3. Wiki.js Setup
- [ ] Access http://192.168.10.23
- [ ] Complete setup wizard
- [ ] Create admin account (store in Vaultwarden)
- [ ] Configure Git sync with Gitea
- [ ] Import existing documentation
- [ ] Test content creation

---

## Deployment Scripts

All automated deployment scripts located in `/home/emesix/Proxmox-Based-Homelab/automation/`:
- `deploy-postgresql-ct100.sh` (CT101)
- `deploy-vaultwarden-ct102.sh`
- `deploy-gitea-ct103.sh`
- `deploy-wikijs-ct104.sh`

---

## Backup Strategy

### PostgreSQL
- **Method:** pg_dump for each database
- **Frequency:** Daily at 2 AM (to be automated)
- **Retention:** 7 daily, 4 weekly
- **Location:** datastore/backups

### ZFS Snapshots
```bash
# On pve-hx310-db host
zfs snapshot rpool/postgres@$(date +%Y%m%d)
zfs snapshot rpool/vaultwarden@$(date +%Y%m%d)
zfs snapshot datastore/gitea@$(date +%Y%m%d)
```

### Vaultwarden
- **Method:** Vault export (encrypted JSON)
- **Frequency:** Weekly manual (until automated)
- **Location:** Secure off-site location

### Gitea
- **Method:** Git mirror to GitHub + ZFS snapshots
- **Frequency:** Continuous (mirror) + daily (ZFS)

### Wiki.js
- **Method:** Git sync + PostgreSQL backup
- **Frequency:** Continuous (Git sync) + daily (DB backup)

---

## Service Dependencies

```
PostgreSQL (CT101)
    ├── Vaultwarden (CT102) - depends on DB
    ├── Gitea (CT103) - depends on DB
    └── Wiki.js (CT104) - depends on DB

Gitea (CT103)
    └── Wiki.js (CT104) - Git sync source
```

**Startup Order:**
1. PostgreSQL must start first
2. Other services can start in any order

---

## Testing Verification

All services tested and verified:
- ✅ PostgreSQL: Remote connections working
- ✅ Vaultwarden: Web UI accessible, admin panel accessible
- ✅ Gitea: Web UI accessible, setup wizard ready
- ✅ Wiki.js: Web UI accessible, setup wizard ready

---

## Next Steps

### Immediate (User Action Required)
1. Complete Vaultwarden setup and store all credentials
2. Complete Gitea setup and mirror repository
3. Complete Wiki.js setup and configure Git sync

### Short-term
1. Set up automated PostgreSQL backups
2. Configure ZFS snapshot scheduling
3. Test backup/restore procedures
4. Document runbook procedures

### Future Enhancements
1. Configure HTTPS/SSL (Traefik reverse proxy)
2. Implement VLAN segmentation (move to 10.10.x.x)
3. Set up monitoring (Prometheus/Grafana)
4. Configure email notifications
5. Implement 2FA for all services

---

## Troubleshooting

### Quick Health Check
```bash
# From pve-hx310-db or workstation
ssh root@192.168.10.12 "
  pct status 101 && \
  pct status 102 && \
  pct status 103 && \
  pct status 104
"
```

### Service Status
```bash
# PostgreSQL
ssh root@192.168.10.20 "systemctl status postgresql@15-main"

# Vaultwarden
ssh root@192.168.10.21 "cd /opt/vaultwarden && docker compose ps"

# Gitea
ssh root@192.168.10.22 "systemctl status gitea"

# Wiki.js
ssh root@192.168.10.23 "cd /opt/wikijs && docker compose ps"
```

---

## Success Criteria - ACHIEVED ✅

- [x] All 4 services deployed and accessible
- [x] PostgreSQL serving all 3 databases
- [x] Services using appropriate storage (NVMe for fast I/O, SATA for repos)
- [x] All services tested and verified running
- [x] Documentation created for all services
- [x] Deployment scripts created and tested
- [x] Node CPU usage < 50% (actual: ~25%)
- [x] Node RAM usage < 20GB (actual: ~14GB)

**Deployment Status:** COMPLETE AND OPERATIONAL
