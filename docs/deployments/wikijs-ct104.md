# Wiki.js Documentation Platform (CT104)

**Deployed:** 2025-11-30  
**Node:** pve-hx310-db (breintrein) - 192.168.10.12  
**Container ID:** 104  
**Hostname:** wiki-brein.internal  
**IP Address:** 192.168.10.23/16  

## Container Specifications

- **Type:** Privileged LXC Container (Docker-enabled)
- **OS:** Debian 12 Bookworm
- **CPU:** 1 core
- **RAM:** 2GB
- **Swap:** 1GB
- **Root Storage:** 20GB on local-zfs
- **Data Storage:** /opt/wikijs (container filesystem)

## Wiki.js Configuration

- **Version:** 2.x (latest - requarks/wiki:2 Docker image)
- **Data Directory:** /opt/wikijs/data
- **Repository Directory:** /opt/wikijs/repo
- **Web Interface:** http://192.168.10.23
- **Setup Wizard:** http://192.168.10.23 (on first access)

### Docker Compose Configuration

Located at: `/opt/wikijs/docker-compose.yml`

**Environment Variables:**
- `DB_TYPE`: postgres
- `DB_HOST`: 192.168.10.20
- `DB_PORT`: 5432
- `DB_USER`: wikijs
- `DB_PASS`: From /tmp/pw3 (to be stored in Vaultwarden)
- `DB_NAME`: wikijs

**Ports:**
- Container port 3000 mapped to host port 80

## Database Configuration

- **Database Server:** PostgreSQL on CT101 (192.168.10.20)
- **Database Name:** wikijs
- **Database User:** wikijs
- **Password:** Stored in /tmp/pw3 (to be moved to Vaultwarden)

Database permissions:
```sql
GRANT ALL ON SCHEMA public TO wikijs;
ALTER DATABASE wikijs OWNER TO wikijs;
```

## Initial Setup

### Access the Setup Wizard

1. **Navigate to:** http://192.168.10.23
2. **Setup wizard** will appear on first access
3. **Complete the setup:**
   - Administrator Email: Your email
   - Administrator Password: Strong password (store in Vaultwarden)
   - Site URL: `http://192.168.10.23`
   - Telemetry: Disable for privacy

### Post-Setup Configuration

After completing the setup wizard:

1. **Log in** with your admin credentials
2. **Configure settings** (Administration → General)
3. **Set up Git sync** (see Git Sync section below)
4. **Import existing documentation** from repository

## Git Sync Configuration

### Sync with Gitea Repository

After mirroring your homelab repository to Gitea (CT103), configure Wiki.js to sync:

1. **Administration → Storage**
2. **Git → Configure**
3. **Settings:**
   - **Authentication Type:** Basic
   - **Repository URL:** `http://192.168.10.22:3000/username/proxmox-homelab.git`
   - **Branch:** `main`
   - **Username:** Your Gitea username
   - **Password/Token:** Your Gitea password or access token
   - **Local Repository Path:** `/wiki/repo`
   - **Sync Direction:** Bi-directional (or Pull only)
   - **Sync Schedule:** Every 5 minutes (or custom)
4. **Save and Test**
5. **Initial Import:** Click "Import Everything" to sync existing docs

### Content Path Mapping

- **Repository Root:** Points to repository root
- **Docs Folder:** If docs are in `docs/` folder, set base path accordingly
- **Asset Handling:** Configure how images/files are handled

## Container Management

### Start/Stop/Restart

```bash
# Inside CT104
cd /opt/wikijs
docker compose start
docker compose stop
docker compose restart
```

### View Logs

```bash
docker compose logs -f
```

### Update Wiki.js

```bash
cd /opt/wikijs
docker compose pull
docker compose up -d
```

## Content Management

### Creating Pages

1. Click "New Page" or "+" button
2. Choose page type (Markdown, HTML, etc.)
3. Enter content
4. Save

### Organizing Content

- **Folders:** Use forward slashes in page paths (e.g., `/guides/setup`)
- **Tags:** Add tags for categorization
- **Navigation:** Configure in Administration → Navigation

### Markdown Features

Wiki.js supports:
- Standard Markdown
- Code blocks with syntax highlighting
- Tables
- Task lists
- Mermaid diagrams
- Mathematical expressions (KaTeX)

## Backup Strategy

### Database Backup

Included in PostgreSQL backup strategy (CT101).

### Content Backup

Content is stored in PostgreSQL and synced to Git:
- **Git Repository:** Automatic backup via Gitea mirror
- **Database:** Covered by PostgreSQL backups
- **Docker Volumes:** /opt/wikijs/data and /opt/wikijs/repo

### Manual Export

```bash
# Inside CT104
cd /opt/wikijs
docker compose exec wikijs node wiki dump
```

## Testing

Web interface accessibility verified:
```bash
curl -I http://192.168.10.23/
# HTTP/1.1 200 OK
```

Service status verified:
```bash
docker compose ps
# wikijs: Up
```

Database connection verified from logs:
- "Database Connection Successful [ OK ]"

## Security Considerations

- **HTTPS:** Not configured (internal network only)
- **Authentication:** Required for editing (can be configured)
- **Public Access:** Can be set to require login for viewing
- **Database:** Using PostgreSQL with secure password
- **Network:** Internal 192.168.10.0/16 only
- **Git Credentials:** Store in Vaultwarden, use access tokens

## Integration with Gitea

### Workflow

1. **Edit in Wiki.js** → Changes committed to local repo
2. **Git Sync** → Changes pushed to Gitea
3. **Gitea Mirror** → Changes synced to GitHub
4. **Result:** Documentation accessible via:
   - Wiki.js web interface (formatted, searchable)
   - Gitea (Git repository browser)
   - GitHub (upstream source)

### Two-Way Sync

If bi-directional sync is enabled:
- Changes made in Wiki.js → pushed to Gitea
- Changes made in Git (Gitea/GitHub) → pulled to Wiki.js

## Access Control

### User Management

1. **Administration → Users**
2. **Add users** or configure authentication providers
3. **Assign groups** for permissions

### Authentication Providers

Supported:
- Local accounts
- LDAP/Active Directory
- OAuth2 (GitHub, GitLab, etc.)
- SAML

For homelab, local accounts are sufficient initially.

## Customization

### Theme and Appearance

- **Administration → Theme**
- Choose color scheme
- Upload custom logo
- Set favicon

### Search Configuration

- **Administration → Search Engine**
- Default: Database Search
- Can configure Elasticsearch for advanced search

## Next Steps

1. **Access Wiki.js:** http://192.168.10.23
2. **Complete setup wizard**
3. **Create admin account** (store credentials in Vaultwarden)
4. **Configure Git sync** with Gitea (http://192.168.10.22:3000)
5. **Import existing documentation** from repository
6. **Test bi-directional sync**
7. **Create first documentation pages**

## Deployment Script

Automated deployment: `/home/emesix/Proxmox-Based-Homelab/automation/deploy-wikijs-ct104.sh`

## Troubleshooting

### Container won't start
- Check Docker service: `systemctl status docker`
- Check logs: `docker compose logs`
- Verify database connectivity: `ping 192.168.10.20`

### Database connection errors
- Verify PostgreSQL is running on CT101
- Check database permissions (see Database Configuration)
- Test connection: `PGPASSWORD=<pw> psql -h 192.168.10.20 -U wikijs -d wikijs`

### Git sync fails
- Verify Gitea is accessible: `curl http://192.168.10.22:3000`
- Check Git credentials in Wiki.js settings
- Review Wiki.js logs for sync errors
- Ensure repository exists in Gitea

### Setup wizard doesn't appear
- Clear browser cache
- Check if setup was already completed (config.yml exists)
- Verify database is empty/new

## Additional Resources

- **Wiki.js Documentation:** https://docs.requarks.io
- **Git Storage Documentation:** https://docs.requarks.io/storage/git
- **Docker Installation:** https://docs.requarks.io/install/docker
