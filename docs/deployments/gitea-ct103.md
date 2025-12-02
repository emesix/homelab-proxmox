# Gitea Git Server (CT103)

**Deployed:** 2025-11-30  
**Node:** pve-hx310-db (breintrein) - 192.168.10.12  
**Container ID:** 103  
**Hostname:** codekroeg.internal  
**IP Address:** 192.168.10.22/16  

## Container Specifications

- **Type:** Unprivileged LXC Container
- **OS:** Debian 12 Bookworm
- **CPU:** 1 core
- **RAM:** 2GB
- **Swap:** 1GB
- **Root Storage:** 20GB on local-zfs
- **Repository Storage:** /var/lib/gitea/repositories (datastore/gitea ZFS dataset)

## Gitea Configuration

- **Version:** 1.25.2
- **Binary:** /usr/local/bin/gitea
- **Configuration:** /etc/gitea/app.ini
- **Work Directory:** /var/lib/gitea
- **Web Interface:** http://192.168.10.22:3000
- **SSH Access:** ssh://git@192.168.10.22:22

### Storage Details

- **ZFS Dataset:** datastore/gitea (on SATA SSD)
- **Dataset Properties:**
  - compression=lz4
  - atime=off
- **Mountpoint:** /datastore/gitea (host) → /var/lib/gitea/repositories (container)
- **Permissions:** UID 100103:100112 (host) = git:git (container)

### Database Configuration

- **Database Server:** PostgreSQL on CT101 (192.168.10.20)
- **Database Name:** gitea
- **Database User:** gitea
- **Password:** Stored in /tmp/pw2 (to be moved to Vaultwarden)

Database permissions:
```sql
GRANT ALL ON SCHEMA public TO gitea;
ALTER DATABASE gitea OWNER TO gitea;
```

## Initial Setup

### Access the Installation Wizard

1. **Navigate to:** http://192.168.10.22:3000
2. **Installation page** will appear on first access
3. Database settings are pre-configured in app.ini
4. **Complete the setup:**
   - Database: Already configured (PostgreSQL)
   - Admin account: Create your admin user
   - Email settings: Can be skipped for now
   - Server and Third-Party settings: Use defaults or customize

### Important Configuration Options

**Server Settings:**
- Domain: `192.168.10.22`
- HTTP Port: `3000`
- Application URL: `http://192.168.10.22:3000/`
- SSH Server Port: `22`
- LFS Server: Enabled

**Repository Settings:**
- Default Branch: `main`
- Default Visibility: `private`

**Security Settings:**
- Registration: Enabled initially (disable after creating accounts)
- Email Confirmation: Disabled

## Service Management

### Systemd Service

```bash
# Inside CT103
systemctl status gitea
systemctl start gitea
systemctl stop gitea
systemctl restart gitea
```

### View Logs

```bash
# Real-time logs
journalctl -u gitea -f

# Recent logs
journalctl -u gitea -n 100
```

## Git Usage

### Clone via HTTP

```bash
git clone http://192.168.10.22:3000/username/repository.git
```

### Clone via SSH

```bash
git clone ssh://git@192.168.10.22/username/repository.git
```

### Add SSH Key

1. Log in to Gitea web interface
2. Settings → SSH / GPG Keys
3. Add your public SSH key

## Mirroring GitHub Repository

### Mirror the Homelab Repository

1. Log in to Gitea as admin
2. Click "+" → "New Migration"
3. **Clone from URL:** `https://github.com/emesix/homelab-proxmox.git`
4. **Owner:** Select your user or create organization "homelab"
5. **Repository Name:** `proxmox-homelab`
6. **Visibility:** Private
7. **Migration Type:** Mirror (keeps in sync with upstream)
8. Click "Migrate Repository"

### Set up Auto-Sync

Mirror repositories can be configured to sync automatically:
1. Repository → Settings → Mirror Settings
2. Set sync interval (e.g., every 8 hours)
3. Enable "Sync on commit"

## Access Control

### Create Organization (Optional)

1. Click "+" → "New Organization"
2. Name: `homelab`
3. Add team members as needed

### User Management

- **Registration:** Enabled by default
- **To disable:** Edit /etc/gitea/app.ini, set `DISABLE_REGISTRATION = true`, restart service
- **Admin users:** Can manage all repositories and users

## Backup Strategy

### Repository Backup

Repositories are stored on ZFS dataset:
```bash
# On pve-hx310-db host
zfs snapshot datastore/gitea@$(date +%Y%m%d)
```

### Full Gitea Backup

```bash
# Inside CT103 as git user
su - git
cd /var/lib/gitea
gitea dump -c /etc/gitea/app.ini
```

Creates a ZIP file with:
- All repositories
- Database dump
- Configuration files
- Custom files

### Database Backup

Included in PostgreSQL backup strategy (CT101).

## Testing

Web interface accessibility verified:
```bash
curl -I http://192.168.10.22:3000/
# HTTP/1.1 200 OK
```

Service status verified:
```bash
systemctl status gitea
# Active: active (running)
```

## Security Considerations

- **HTTPS:** Not configured (internal network only)
- **Registration:** Enabled - disable after creating necessary accounts
- **SSH Keys:** Required for SSH access
- **Database:** Using PostgreSQL with secure password
- **Network:** Internal 192.168.10.0/16 only
- **Container:** Unprivileged LXC for better isolation

## Updating Gitea

### Update Binary

```bash
# Inside CT103
# Download latest version
GITEA_VERSION=$(curl -s https://api.github.com/repos/go-gitea/gitea/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
wget -O /tmp/gitea https://dl.gitea.com/gitea/${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64

# Stop service
systemctl stop gitea

# Backup current binary
cp /usr/local/bin/gitea /usr/local/bin/gitea.backup

# Replace binary
mv /tmp/gitea /usr/local/bin/gitea
chmod +x /usr/local/bin/gitea

# Start service
systemctl start gitea
```

## Next Steps

1. **Access Gitea:** http://192.168.10.22:3000
2. **Complete installation wizard**
3. **Create admin account** (store credentials in Vaultwarden)
4. **Add your SSH key** for git operations
5. **Mirror GitHub repository:** emesix/homelab-proxmox
6. **Disable registration** after creating accounts
7. **Test git clone/push/pull** operations
8. **Proceed with Wiki.js deployment** (CT104)

## Deployment Script

Automated deployment: `/home/emesix/Proxmox-Based-Homelab/automation/deploy-gitea-ct103.sh`

## Troubleshooting

### Service won't start
- Check logs: `journalctl -u gitea -n 50`
- Verify database connectivity: `PGPASSWORD=<pw> psql -h 192.168.10.20 -U gitea -d gitea`
- Check permissions: `ls -l /var/lib/gitea/`

### Database connection errors
- Verify PostgreSQL is running on CT101
- Check database permissions (see Database Configuration)
- Verify /etc/gitea/app.ini has correct password

### Repository permission errors
- Check ZFS dataset mount: `df -h /var/lib/gitea/repositories`
- Verify ownership: `ls -ld /var/lib/gitea/repositories` (should be git:git)
- Host-side permissions: `ls -ld /datastore/gitea` (should be 100103:100112)

### SSH access issues
- Verify SSH is running in container: `ps aux | grep sshd`
- Check Gitea SSH server: `systemctl status gitea`
- Test SSH: `ssh -T git@192.168.10.22`
