# Community Helper Scripts - Experience Report

**Date:** 2025-11-30  
**Context:** Deploying core services (PostgreSQL, Vaultwarden, Gitea, Wiki.js) on pve-hx310-db  
**Scripts Repository:** https://github.com/community-scripts/ProxmoxVE  
**Deployment Approach:** Initially attempted community scripts, pivoted to custom automation

---

## Executive Summary

**Recommendation:** Use community helper scripts selectively, NOT for production core infrastructure deployment.

**Best Use Cases for Helper Scripts:**
- ✅ PVE Post-Install (repository configuration, updates)
- ✅ Quick testing/evaluation of software
- ✅ Non-critical workloads
- ✅ Learning/exploration

**Avoid Helper Scripts For:**
- ❌ Core infrastructure (databases, critical services)
- ❌ Services requiring specific storage configurations
- ❌ Automated/unattended deployments
- ❌ Production environments where you need full control

---

## Timeline of Events

### Initial Approach (Failed)
1. **Cloned community scripts repository** to `/home/emesix/Proxmox-Based-Homelab/community-scripts/`
2. **Attempted PostgreSQL deployment** using `ct/postgresql.sh`
3. **Result:** Multiple failures due to TUI requirements and automation incompatibilities

### Problems Encountered

#### Problem 1: TUI/Interactive Requirements
**Script:** `ct/postgresql.sh`  
**Issue:** Scripts designed for interactive terminal sessions, not automation

**Error Messages:**
```
TERM environment variable not set.
dialog: Error opening terminal: unknown.
whiptail: Cannot initialize terminal
```

**Root Cause:**
- Scripts use `whiptail`, `dialog`, and other TUI (Text User Interface) tools
- Designed to run in interactive SSH sessions, not via `pct exec` or piped commands
- No flags to disable interactive mode

**Impact:** Complete deployment failure when running remotely or in automation

#### Problem 2: DNS Resolution Failures
**Context:** Manual LXC creation before trying helper script  
**Issue:** Container couldn't resolve domain names

**Error:**
```
Temporary failure in name resolution
Could not resolve 'deb.debian.org'
```

**Attempted Fix:**
- Set nameserver to 8.8.8.8 in container config
- Still failed in automated context

**Root Cause:**
- Container networking not fully initialized in automated deployment
- Helper scripts assume working DNS from the start

#### Problem 3: Template Download Issues
**Issue:** Helper scripts tried to download templates that already existed or had naming mismatches

**Error:**
```
Template not found: debian-12-standard_12.7-1_amd64.tar.zst
Actual template: debian-12-standard_12.12-1_amd64.tar.zst
```

**Root Cause:**
- Scripts hard-coded specific template versions
- No logic to use latest available template
- Assumes specific Proxmox VE configuration

#### Problem 4: Lack of Customization
**Issue:** Helper scripts made assumptions about:
- Storage locations (always `local` or `local-lvm`)
- Network configuration (DHCP by default)
- Resource allocation (fixed RAM/CPU)
- Installation paths
- Database locations

**Impact:**
- Could not use custom ZFS datasets for PostgreSQL data
- Could not specify static IPs easily
- Could not optimize for our specific hardware
- No control over storage tiering (NVMe vs SATA)

#### Problem 5: Error Handling
**Issue:** Scripts would fail silently or with cryptic errors

**Example:**
- Container created (CT100)
- Installation failed mid-process
- Container left in broken state
- Had to manually destroy and clean up

**No Rollback:**
- Scripts didn't clean up after failures
- Left orphaned containers, templates, configurations

---

## What We Learned

### 1. Helper Scripts Philosophy
The community helper scripts are designed for:
- **Interactive use** by administrators via SSH
- **Quick deployment** of standard configurations
- **Convenience** over control
- **Broadest compatibility** (not optimized for specific setups)

They are NOT designed for:
- Automated/CI-CD style deployments
- Custom storage configurations
- Production environments requiring specific optimizations
- Repeatable, version-controlled infrastructure

### 2. Documentation Limitations
The scripts themselves had:
- ❌ Limited inline documentation
- ❌ No clear list of dependencies/requirements
- ❌ No "automation-friendly" mode flags
- ❌ Assumptions not clearly documented

### 3. Integration Issues
When using helper scripts in our environment:
- Could not integrate with our ZFS storage strategy
- Could not pre-configure database users/passwords securely
- Could not customize PostgreSQL tuning parameters
- Could not ensure idempotent deployments

---

## Our Solution: Custom Deployment Scripts

### Why We Built Our Own

After encountering repeated failures, we created custom deployment scripts:
- `automation/deploy-postgresql-ct100.sh`
- `automation/deploy-vaultwarden-ct102.sh`
- `automation/deploy-gitea-ct103.sh`
- `automation/deploy-wikijs-ct104.sh`

### Advantages of Custom Scripts

#### 1. Full Control
```bash
# Custom script example - exact control over resources
pct create $CT_ID local:vztmpl/$TEMPLATE \
  --hostname $HOSTNAME \
  --cores $CORES \
  --memory $RAM \
  --swap $SWAP \
  --rootfs $STORAGE:$DISK \
  --net0 name=eth0,bridge=vmbr0,ip=$IP,gw=$GW \
  --features nesting=1 \
  --unprivileged 0
```

**Benefits:**
- Specify exact resources needed
- Choose storage backend
- Set static IPs
- Control privileged/unprivileged mode

#### 2. Storage Strategy Integration
```bash
# Mount custom ZFS datasets
pct set 101 -mp0 /rpool/postgres,mp=/mnt/postgres

# Optimize for database workload
zfs set recordsize=16K compression=lz4 rpool/postgres
```

**Benefits:**
- NVMe for hot data (PostgreSQL, Vaultwarden)
- SATA SSD for cold data (Gitea repos, backups)
- Proper ZFS tuning per workload

#### 3. Automation-Friendly
```bash
# No interactive prompts
export DEBIAN_FRONTEND=noninteractive
apt-get install -y postgresql postgresql-contrib

# Pre-configured settings
cat > /etc/gitea/app.ini <<EOF
[database]
DB_TYPE = postgres
DB_HOST = 192.168.10.20
...
EOF
```

**Benefits:**
- Runs via SSH without TTY
- Can be version controlled
- Repeatable deployments
- Can be run in CI/CD pipelines

#### 4. Security
```bash
# Passwords generated securely, never hard-coded
PW1=$(openssl rand -base64 32)

# Stored temporarily, documented for Vaultwarden
echo "$PW1" > /tmp/pw1
```

**Benefits:**
- No passwords in scripts
- Secure generation
- Clear path to secure storage (Vaultwarden)

#### 5. Error Handling
```bash
set -e  # Exit on error

# Explicit error messages
if ! systemctl start postgresql; then
    echo "ERROR: PostgreSQL failed to start"
    exit 1
fi
```

**Benefits:**
- Scripts fail fast
- Clear error messages
- Can add cleanup logic

---

## Comparison: Helper Scripts vs Custom Scripts

| Aspect | Community Scripts | Custom Scripts |
|--------|------------------|----------------|
| **Setup Time** | Very fast (5-10 min) | Moderate (30-60 min initial) |
| **Control** | Limited | Complete |
| **Customization** | Minimal | Full |
| **Automation** | Difficult | Easy |
| **Storage Config** | Basic | Advanced (ZFS optimization) |
| **Networking** | DHCP default | Full control (static IPs, VLANs) |
| **Security** | Basic | Custom (secure passwords, hardening) |
| **Repeatability** | Inconsistent | Deterministic |
| **Documentation** | External | Self-documented |
| **Version Control** | N/A | Git-tracked |
| **Troubleshooting** | Difficult (TUI errors) | Clear (explicit errors) |
| **Production Ready** | No | Yes |

---

## Specific Script Issues Encountered

### PostgreSQL Helper Script (`ct/postgresql.sh`)

**Attempted Use:** Deploy PostgreSQL database server  
**Result:** ❌ Failed

**Issues:**
1. Required interactive terminal (whiptail dialogs)
2. No option to specify custom storage location
3. Couldn't pre-configure remote access
4. No performance tuning options
5. Default passwords or interactive password entry

**What We Needed:**
- PostgreSQL data on ZFS dataset with 16K recordsize
- Remote access for 192.168.10.0/16
- Performance tuning for 8GB RAM
- Pre-configured databases and users
- Secure password generation

**Solution:**
Custom script with:
```bash
# Custom storage
zfs create rpool/postgres
zfs set recordsize=16K compression=lz4 rpool/postgres

# Custom performance tuning
shared_buffers = 2GB
effective_cache_size = 6GB
random_page_cost = 1.1  # ZFS on SSD

# Pre-configured remote access
echo 'host all all 192.168.10.0/16 md5' >> pg_hba.conf
```

### Vaultwarden Helper Script (`ct/vaultwarden.sh`)

**Not Attempted** (learned from PostgreSQL failure)

**Predicted Issues:**
- Would use default storage locations
- Couldn't integrate with our PostgreSQL instance
- No control over admin token generation
- Likely HTTPS configuration we don't need yet

**Our Custom Approach:**
- Docker Compose for easy updates
- PostgreSQL backend (more secure than SQLite)
- ZFS dataset on NVMe for performance
- Custom admin token generation
- Clear path to add reverse proxy later

---

## Recommended Approach

### When to Use Helper Scripts

**Good Use Cases:**
1. **PVE Post-Install Script**
   ```bash
   bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"
   ```
   - Updates repositories
   - Removes enterprise repo nag
   - Safe and useful

2. **Testing/Evaluation**
   - Quick deployment to try out software
   - Not for production
   - Easy to delete and redeploy

3. **Non-Critical Services**
   - Media servers (Plex, Jellyfin)
   - Download clients
   - Home automation (if not critical)

### When to Write Custom Scripts

**Critical Use Cases:**
1. **Core Infrastructure**
   - Databases
   - Authentication services
   - Network services (DNS, DHCP)
   
2. **Custom Storage Requirements**
   - ZFS datasets
   - Storage tiering
   - Specific mount points

3. **Production Services**
   - Services requiring uptime
   - Services with compliance requirements
   - Services needing specific security configurations

4. **Automated Deployments**
   - CI/CD pipelines
   - Infrastructure as Code
   - Disaster recovery scenarios

---

## Lessons for Future Deployments

### 1. Start Simple
```bash
# Basic LXC creation is straightforward
pct create $CT_ID $TEMPLATE \
  --hostname $HOSTNAME \
  --net0 name=eth0,bridge=vmbr0,ip=$IP,gw=$GW
```

Don't overcomplicate - basic `pct` commands are well-documented and reliable.

### 2. Layer Configuration
```bash
# 1. Create container
pct create ...

# 2. Start and wait
pct start $CT_ID
sleep 10

# 3. Install base packages
pct exec $CT_ID -- apt-get update
pct exec $CT_ID -- apt-get install -y <packages>

# 4. Configure service
pct exec $CT_ID -- bash -c "cat > /etc/config <<EOF
...
EOF"

# 5. Start service
pct exec $CT_ID -- systemctl enable service
pct exec $CT_ID -- systemctl start service
```

Step-by-step approach allows debugging at each stage.

### 3. Use Configuration Management (Future)

For larger deployments, consider:
- **Ansible** - Playbooks for service configuration
- **Terraform** - Infrastructure provisioning
- **Salt/Puppet** - Configuration management

But for homelab scale (< 10 services), bash scripts are sufficient and more transparent.

### 4. Document Everything

Our custom scripts are:
- Self-documenting (clear variable names, comments)
- Version controlled (Git)
- Accompanied by markdown docs
- Include next steps and troubleshooting

### 5. Test Before Production

Always test custom scripts on:
- Test containers first
- Document any manual steps needed
- Verify cleanup after failures
- Test backup/restore procedures

---

## Conclusions

### Helper Scripts Have Their Place

The community helper scripts are valuable for:
- Quick exploration and learning
- Non-critical deployments
- Standard configurations
- Interactive use cases

### But Not for Everything

For production homelab infrastructure:
- Custom scripts provide necessary control
- Better integration with specific hardware/storage
- Automation-friendly
- Maintainable and version-controlled

### Our Recommendation

**Hybrid Approach:**
1. Use `post-pve-install.sh` for Proxmox host setup
2. Write custom scripts for core services
3. Consider helper scripts for auxiliary services (media servers, etc.)
4. Always version control your custom scripts
5. Document your decisions and configurations

---

## Results

**What We Achieved with Custom Scripts:**

✅ **PostgreSQL (CT101)**
- Deployed successfully
- Data on optimized ZFS dataset
- Performance tuned
- Remote access configured
- 3 databases pre-created

✅ **Vaultwarden (CT102)**
- PostgreSQL backend
- Secure admin token
- Docker Compose for easy updates
- Clear upgrade path

✅ **Gitea (CT103)**
- Repositories on SATA SSD (appropriate tier)
- PostgreSQL backend
- Unprivileged container (better security)
- Ready for GitHub mirroring

✅ **Wiki.js (CT104)**
- PostgreSQL backend
- Git sync capable
- Clean Docker deployment
- Ready for documentation

**Total Deployment Time:** ~2 hours including:
- Initial helper script attempts (failures)
- Writing custom scripts
- Testing and iteration
- Documentation

**Time Investment vs Value:**
- Helper scripts: Would have been 30 min if they worked
- Custom scripts: 2 hours initial, but now we have:
  - Repeatable deployments
  - Full documentation
  - Version-controlled automation
  - Foundation for future services

---

## Future Improvements

### Script Enhancements
1. Add idempotency checks (don't recreate if exists)
2. Add cleanup functions (rollback on failure)
3. Add validation steps (test each stage)
4. Create unified deployment orchestrator

### Process Improvements
1. Create script templates for common patterns
2. Build library of reusable functions
3. Add comprehensive error messages
4. Create testing framework for scripts

### Documentation
1. Create runbooks for each service
2. Document common troubleshooting scenarios
3. Create disaster recovery procedures
4. Maintain change log for all deployments

---

## Final Thoughts

**The community helper scripts taught us valuable lessons** - mainly that for production infrastructure, you need control, repeatability, and transparency. While they didn't work for our core services deployment, the attempt helped us understand what we actually needed and led us to build better, more maintainable automation.

**Would we recommend others try helper scripts?** Yes, but with realistic expectations. They're excellent learning tools and quick deployment aids, but not substitutes for proper infrastructure-as-code practices.

**Our final infrastructure is better because:**
- We understand every component
- We can reproduce it
- We can maintain it
- We documented it
- We own it

And that's worth the extra time investment.
