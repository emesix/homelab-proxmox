# Vaultwarden Password Manager (CT102)

**Deployed:** 2025-11-30  
**Node:** pve-hx310-db (breintrein) - 192.168.10.12  
**Container ID:** 102  
**Hostname:** kluisbaas.internal  
**IP Address:** 192.168.10.21/16  

## Container Specifications

- **Type:** Privileged LXC Container (Docker-enabled)
- **OS:** Debian 12 Bookworm
- **CPU:** 1 core
- **RAM:** 2GB
- **Swap:** 1GB
- **Root Storage:** 20GB on local-zfs
- **Data Storage:** /opt/vaultwarden (rpool/vaultwarden ZFS dataset)

## Vaultwarden Configuration

- **Version:** Latest (vaultwarden/server:latest Docker image)
- **Data Directory:** /opt/vaultwarden/data
- **Web Interface:** http://192.168.10.21
- **Admin Panel:** http://192.168.10.21/admin

### Storage Details

- **ZFS Dataset:** rpool/vaultwarden
- **Dataset Properties:**
  - compression=lz4
  - atime=off
- **Mountpoint:** /rpool/vaultwarden (host) → /opt/vaultwarden (container)

### Docker Compose Configuration

Located at: `/opt/vaultwarden/docker-compose.yml`

**Environment Variables:**
- `DATABASE_URL`: PostgreSQL connection to 192.168.10.20:5432/vaultwarden
- `DOMAIN`: http://192.168.10.21
- `SIGNUPS_ALLOWED`: true (disable after creating accounts)
- `ADMIN_TOKEN`: Stored in /tmp/vaultwarden-admin-token on workstation
- `LOG_LEVEL`: info

## Database Configuration

- **Database Server:** PostgreSQL on CT101 (192.168.10.20)
- **Database Name:** vaultwarden
- **Database User:** vaultwarden
- **Password:** Stored in /tmp/pw1 (workstation and pve-hx310-db host)

### Database Permissions

```sql
GRANT ALL ON SCHEMA public TO vaultwarden;
ALTER DATABASE vaultwarden OWNER TO vaultwarden;
```

## Access Information

### Admin Panel Access

**URL:** http://192.168.10.21/admin  
**Admin Token:** Stored in `/tmp/vaultwarden-admin-token` on workstation

To access admin panel:
1. Navigate to http://192.168.10.21/admin
2. Enter the admin token from /tmp/vaultwarden-admin-token
3. Configure settings and manage users

### User Registration

**URL:** http://192.168.10.21  
**Initial State:** Signups enabled

**IMPORTANT:** After creating your primary account, disable signups:
1. Access admin panel
2. Go to Settings
3. Set `SIGNUPS_ALLOWED=false` in docker-compose.yml
4. Restart container: `docker compose restart`

## Container Management

### Start/Stop/Restart

```bash
# Inside CT102
cd /opt/vaultwarden
docker compose start
docker compose stop
docker compose restart
```

### View Logs

```bash
docker compose logs -f
```

### Update Vaultwarden

```bash
cd /opt/vaultwarden
docker compose pull
docker compose up -d
```

## Testing

Web interface accessibility verified:
```bash
curl -I http://192.168.10.21/
# HTTP/1.1 200 OK

curl -I http://192.168.10.21/admin
# HTTP/1.1 200 OK
```

## Security Considerations

- **Admin Token:** Plain text (consider upgrading to Argon2 hash - see Vaultwarden docs)
- **HTTPS:** Not configured (internal network only)
- **Signups:** Enabled initially - MUST disable after account creation
- **Database:** Using PostgreSQL (more secure than SQLite)
- **Network:** Internal 192.168.10.0/16 only

## Backup Strategy

### ZFS Snapshots
```bash
# On pve-hx310-db host
zfs snapshot rpool/vaultwarden@$(date +%Y%m%d)
```

### Vaultwarden Export
1. Log in to Vaultwarden web interface
2. Settings → Export Vault
3. Save encrypted JSON export to secure location

### Database Backup
Included in PostgreSQL backup strategy (CT101).

## Next Steps

1. **Access Vaultwarden:** http://192.168.10.21
2. **Create primary account** (use strong master password!)
3. **Store critical credentials:**
   - PostgreSQL passwords (/tmp/pw1, pw2, pw3)
   - Vaultwarden admin token
   - Root passwords for staging environment
4. **Disable signups** in docker-compose.yml
5. **Export vault** as backup
6. **Proceed with Gitea deployment** (CT103)

## Deployment Script

Automated deployment: `/home/emesix/Proxmox-Based-Homelab/automation/deploy-vaultwarden-ct102.sh`

## Troubleshooting

### Container won't start
- Check Docker service: `systemctl status docker`
- Check logs: `docker compose logs`
- Verify database connectivity: `ping 192.168.10.20`

### Database connection errors
- Verify PostgreSQL is running on CT101
- Check database permissions (see Database Configuration section)
- Test connection: `PGPASSWORD=<pw> psql -h 192.168.10.20 -U vaultwarden -d vaultwarden`

### Permission errors
- Ensure schema permissions granted (see Database Configuration)
- Verify ZFS dataset permissions: `ls -ld /opt/vaultwarden`
