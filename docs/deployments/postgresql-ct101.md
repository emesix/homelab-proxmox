# PostgreSQL Database Server (CT101)

**Deployed:** 2025-11-30  
**Node:** pve-hx310-db (breintrein) - 192.168.10.12  
**Container ID:** 101  
**Hostname:** pg-brein.internal  
**IP Address:** 192.168.10.20/16  

## Container Specifications

- **Type:** Privileged LXC Container
- **OS:** Debian 12 Bookworm
- **CPU:** 2 cores
- **RAM:** 8GB
- **Swap:** 2GB
- **Root Storage:** 100GB on local-zfs
- **Data Storage:** /mnt/postgres (rpool/postgres ZFS dataset)

## PostgreSQL Configuration

- **Version:** PostgreSQL 15.14
- **Data Directory:** /mnt/postgres/data (symlinked from /var/lib/postgresql/15/main)
- **Configuration:** /etc/postgresql/15/main/postgresql.conf
- **Access Control:** /etc/postgresql/15/main/pg_hba.conf

### Storage Details

- **ZFS Dataset:** rpool/postgres
- **Dataset Properties:**
  - recordsize=16K (optimized for database)
  - compression=lz4
  - atime=off
- **Mountpoint:** /rpool/postgres (host) → /mnt/postgres (container)

### Performance Tuning

```
shared_buffers = 2GB
effective_cache_size = 6GB
maintenance_work_mem = 512MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 64MB
min_wal_size = 1GB
max_wal_size = 4GB
max_connections = 100
```

## Databases and Users

| Database | User | Purpose |
|----------|------|---------|
| vaultwarden | vaultwarden | Password manager backend |
| gitea | gitea | Git server backend |
| wikijs | wikijs | Wiki/documentation backend |

**Passwords:** Stored in /tmp/pw1, /tmp/pw2, /tmp/pw3 on workstation and pve-hx310-db host. Will be migrated to Vaultwarden after deployment.

## Access Configuration

- **Remote Access:** Enabled for 192.168.10.0/16 network
- **Listen Address:** * (all interfaces)
- **Authentication:** MD5 password authentication

## Testing

Remote access verified:
```bash
PGPASSWORD=$(cat /tmp/pw1) psql -h 192.168.10.20 -U vaultwarden -d vaultwarden -c 'SELECT version();'
```

## Next Steps

1. Deploy Vaultwarden (CT102) - password manager
2. Store database credentials in Vaultwarden
3. Deploy Gitea (CT103)
4. Deploy Wiki.js (CT104)
5. Set up automated backup strategy

## Deployment Script

Automated deployment: `/home/emesix/Proxmox-Based-Homelab/automation/deploy-postgresql-ct100.sh`

Note: Script was updated to use CT ID 101 instead of 100 (VMID 100 was already in use by OPNsense on pve-qotom01).
