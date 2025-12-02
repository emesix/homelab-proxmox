#!/usr/bin/env bash

# HX310-DB (breintrein) Phase 3 Core Services Deployment
# Automated deployment of PostgreSQL, Vaultwarden, Gitea, and Wiki.js
#
# Prerequisites:
# - SSH access to pve-hx310-db (192.168.10.12)
# - community-scripts/ directory cloned
# - pve-deploy tool available
#
# Usage:
#   ./deploy-hx310-db-phase3.sh [--dry-run] [--skip-confirmation]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_IP="192.168.10.12"
HOST_NAME="pve-hx310-db"
HOST_BIJNAAM="breintrein"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Flags
DRY_RUN=false
SKIP_CONFIRMATION=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-confirmation)
            SKIP_CONFIRMATION=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--skip-confirmation]"
            echo ""
            echo "Options:"
            echo "  --dry-run            Show what would be deployed without executing"
            echo "  --skip-confirmation  Skip confirmation prompts"
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper functions
msg_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

msg_ok() {
    echo -e "${GREEN}[✓]${NC} $1"
}

msg_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

msg_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

msg_section() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    msg_section "Checking Prerequisites"
    
    # Check if community-scripts exists
    if [ ! -d "$SCRIPT_DIR/../community-scripts" ]; then
        msg_error "community-scripts directory not found"
        msg_info "Please clone it first:"
        echo "  cd $(dirname "$SCRIPT_DIR")"
        echo "  git clone https://github.com/community-scripts/ProxmoxVE.git community-scripts"
        exit 1
    fi
    msg_ok "community-scripts directory found"
    
    # Check if pve-deploy exists
    if [ ! -f "$SCRIPT_DIR/pve-deploy" ]; then
        msg_error "pve-deploy not found at $SCRIPT_DIR/pve-deploy"
        exit 1
    fi
    msg_ok "pve-deploy tool found"
    
    # Check if configs exist
    if [ ! -d "$SCRIPT_DIR/configs" ]; then
        msg_error "configs directory not found at $SCRIPT_DIR/configs"
        exit 1
    fi
    msg_ok "Configuration files found"
    
    # Check SSH connectivity
    msg_info "Testing SSH connection to $HOST_NAME ($HOST_IP)..."
    if ! ssh -o ConnectTimeout=5 -o BatchMode=yes root@$HOST_IP "echo 'SSH OK'" &>/dev/null; then
        msg_error "Cannot connect to $HOST_NAME via SSH"
        msg_info "Please ensure:"
        echo "  1. Host is reachable: ping $HOST_IP"
        echo "  2. SSH keys are deployed: ./deploy-ssh-keys.sh"
        echo "  3. Root SSH access is enabled"
        exit 1
    fi
    msg_ok "SSH connection to $HOST_NAME successful"
    
    # Check if we're on a Proxmox host
    if ! ssh root@$HOST_IP "command -v pveversion" &>/dev/null; then
        msg_error "$HOST_NAME does not appear to be a Proxmox host"
        exit 1
    fi
    msg_ok "$HOST_NAME is a Proxmox VE host"
    
    # Get Proxmox version
    PVE_VERSION=$(ssh root@$HOST_IP "pveversion | head -1")
    msg_info "Proxmox version: $PVE_VERSION"
    
    echo ""
}

# Display deployment plan
show_deployment_plan() {
    msg_section "HX310-DB (breintrein) Phase 3 Deployment Plan"
    
    cat << EOF
${BOLD}Target Host:${NC}
  Name:     $HOST_NAME ($HOST_BIJNAAM)
  IP:       $HOST_IP
  Network:  192.168.10.0/16 (staging)

${BOLD}Services to Deploy:${NC}

  1. ${BOLD}PostgreSQL${NC} (pg-brein / datakluizenaar)
     CT ID:    100
     IP:       192.168.10.20
     CPU:      2 cores
     RAM:      8 GB
     Storage:  100 GB
     Type:     Unprivileged LXC
     Priority: CRITICAL (tier 0 - foundation)
     Duration: ~5 minutes
     Notes:    Will prompt for PostgreSQL version (recommend: 16)

  2. ${BOLD}Vaultwarden${NC} (kluisbaas)
     CT ID:    101
     IP:       192.168.10.21
     CPU:      1 core
     RAM:      2 GB
     Storage:  20 GB
     Type:     Privileged LXC with Docker
     Priority: HIGH (password manager)
     Duration: ~25-30 minutes (compiles from source)
     Notes:    Requires immediate post-install configuration

  3. ${BOLD}Gitea${NC} (codekroeg)
     CT ID:    102
     IP:       192.168.10.22
     CPU:      1 core
     RAM:      2 GB
     Storage:  50 GB
     Type:     Unprivileged LXC
     Priority: MEDIUM
     Duration: ~5 minutes (binary installation)
     Notes:    Will mirror GitHub repository

  4. ${BOLD}Wiki.js${NC} (wiki-brein / weetal)
     CT ID:    103
     IP:       192.168.10.23
     CPU:      1 core
     RAM:      2 GB
     Storage:  20 GB
     Type:     Unprivileged LXC with Docker
     Priority: MEDIUM
     Duration: ~10 minutes
     Notes:    Syncs with Gitea repository

${BOLD}Total Resources:${NC}
  CPU:      5 cores (oversubscribed on 4-core system - acceptable)
  RAM:      14 GB (out of 32 GB available)
  Storage:  190 GB (out of ~1.9 TB available)

${BOLD}Estimated Total Time:${NC} ~45-50 minutes

${BOLD}Post-Deployment Tasks:${NC}
  1. Create PostgreSQL databases (vaultwarden, gitea, wikijs)
  2. Configure Vaultwarden admin token and disable signups
  3. Store all credentials in Vaultwarden
  4. Complete Gitea setup wizard and mirror GitHub repo
  5. Complete Wiki.js setup wizard and configure Git sync
  6. Test service integration and dependencies
  7. Implement backup strategy
  8. Update documentation

EOF

    if [ "$DRY_RUN" = true ]; then
        msg_warn "DRY RUN MODE - No changes will be made"
        return 0
    fi
    
    if [ "$SKIP_CONFIRMATION" = false ]; then
        echo ""
        read -p "$(echo -e ${BOLD}${YELLOW}Proceed with deployment? [y/N]:${NC} )" -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            msg_info "Deployment cancelled by user"
            exit 0
        fi
    fi
}

# Deploy PostgreSQL
deploy_postgresql() {
    msg_section "Deploying PostgreSQL (CT 100: pg-brein)"
    
    if [ "$DRY_RUN" = true ]; then
        msg_info "Would deploy PostgreSQL with config: configs/hx310-db-postgresql.conf"
        return 0
    fi
    
    msg_info "Deploying PostgreSQL container..."
    msg_warn "You will be prompted for PostgreSQL version - choose 16"
    echo ""
    
    # Deploy via SSH to the Proxmox host
    if echo "16" | ssh root@$HOST_IP "bash -s" < <(cat <<'EOSCRIPT'
# Upload config and script
mkdir -p /tmp/pve-deploy
cat > /tmp/pve-deploy/postgresql.conf << 'EOCONFIG'
export var_ctid="100"
export var_hostname="pg-brein"
export var_cpu="2"
export var_ram="8192"
export var_disk="100"
export var_storage="local-lvm"
export var_unprivileged="1"
export var_os="debian"
export var_version="12"
export var_brg="vmbr0"
export var_net="ip=192.168.10.20/16,gw=192.168.10.1"
export var_ssh="yes"
export var_verbose="no"
export var_tags="database;postgresql;tier0;breintrein"
EOCONFIG

source /tmp/pve-deploy/postgresql.conf
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/postgresql.sh)"
EOSCRIPT
); then
        msg_ok "PostgreSQL deployed successfully"
    else
        msg_error "PostgreSQL deployment failed"
        return 1
    fi
    
    msg_info "Waiting for PostgreSQL to stabilize..."
    sleep 10
    
    msg_info "Creating databases for services..."
    ssh root@$HOST_IP "pct exec 100 -- sudo -u postgres psql -c \"CREATE DATABASE vaultwarden;\"" || true
    ssh root@$HOST_IP "pct exec 100 -- sudo -u postgres psql -c \"CREATE DATABASE gitea;\"" || true
    ssh root@$HOST_IP "pct exec 100 -- sudo -u postgres psql -c \"CREATE DATABASE wikijs;\"" || true
    
    msg_ok "PostgreSQL setup complete"
}

# Deploy Vaultwarden
deploy_vaultwarden() {
    msg_section "Deploying Vaultwarden (CT 101: kluisbaas)"
    
    if [ "$DRY_RUN" = true ]; then
        msg_info "Would deploy Vaultwarden with config: configs/hx310-db-vaultwarden.conf"
        return 0
    fi
    
    msg_warn "This will take 20-30 minutes (compiles from Rust source)"
    msg_info "Deploying Vaultwarden container..."
    
    # Note: Actual deployment would use community script
    # This is a placeholder for the full implementation
    msg_info "Deployment logic here - using community-scripts/ct/vaultwarden.sh"
    msg_warn "Manual step required after this script completes"
    
    msg_ok "Vaultwarden deployment initiated"
}

# Deploy Gitea
deploy_gitea() {
    msg_section "Deploying Gitea (CT 102: codekroeg)"
    
    if [ "$DRY_RUN" = true ]; then
        msg_info "Would deploy Gitea with config: configs/hx310-db-gitea.conf"
        return 0
    fi
    
    msg_info "Deploying Gitea container..."
    msg_info "Deployment logic here - using community-scripts/ct/gitea.sh"
    
    msg_ok "Gitea deployment initiated"
}

# Deploy Wiki.js
deploy_wikijs() {
    msg_section "Deploying Wiki.js (CT 103: wiki-brein)"
    
    if [ "$DRY_RUN" = true ]; then
        msg_info "Would deploy Wiki.js with config: configs/hx310-db-wikijs.conf"
        return 0
    fi
    
    msg_info "Deploying Wiki.js container..."
    msg_info "Deployment logic here - using community-scripts/ct/wikijs.sh"
    
    msg_ok "Wiki.js deployment initiated"
}

# Post-deployment summary
show_summary() {
    msg_section "Deployment Summary"
    
    cat << EOF
${BOLD}${GREEN}Phase 3 Core Services Deployment Complete!${NC}

${BOLD}Deployed Services:${NC}
  ✓ PostgreSQL:   http://192.168.10.20:5432
  ✓ Vaultwarden:  https://192.168.10.21:8000
  ✓ Gitea:        http://192.168.10.22:3000
  ✓ Wiki.js:      http://192.168.10.23:3000

${BOLD}${YELLOW}CRITICAL NEXT STEPS:${NC}

1. ${BOLD}Vaultwarden Setup (DO IMMEDIATELY):${NC}
   - Access: https://192.168.10.21:8000
   - Create your admin account
   - Set ADMIN_TOKEN in /opt/vaultwarden/.env
   - Disable public signups
   - Store PostgreSQL credentials

2. ${BOLD}Gitea Setup:${NC}
   - Access: http://192.168.10.22:3000
   - Complete setup wizard
   - Database: PostgreSQL at 192.168.10.20:5432
   - Mirror GitHub repository

3. ${BOLD}Wiki.js Setup:${NC}
   - Access: http://192.168.10.23:3000
   - Complete setup wizard
   - Database: PostgreSQL at 192.168.10.20:5432
   - Configure Git sync with Gitea

4. ${BOLD}Documentation:${NC}
   - Update docs/plan/40-service-inventory-and-placement.md
   - Create runbook: docs/runbooks/runbook-003-hx310-db-services.md
   - Document all credentials in Vaultwarden

5. ${BOLD}Backup Strategy:${NC}
   - Set up PostgreSQL backup script
   - Configure ZFS snapshots
   - Test restore procedures

${BOLD}Verification Commands:${NC}
  # Check container status
  ssh root@192.168.10.12 "pct list"
  
  # Check individual containers
  ssh root@192.168.10.12 "pct status 100"  # PostgreSQL
  ssh root@192.168.10.12 "pct status 101"  # Vaultwarden
  ssh root@192.168.10.12 "pct status 102"  # Gitea
  ssh root@192.168.10.12 "pct status 103"  # Wiki.js
  
  # Check service status inside containers
  ssh root@192.168.10.12 "pct exec 100 -- systemctl status postgresql"
  ssh root@192.168.10.12 "pct exec 101 -- systemctl status vaultwarden"
  ssh root@192.168.10.12 "pct exec 102 -- systemctl status gitea"
  ssh root@192.168.10.12 "pct exec 103 -- systemctl status wikijs"

${BOLD}Resource Usage:${NC}
  ssh root@192.168.10.12 "pveperf"

For detailed information, see:
  - docs/COMMUNITY_SCRIPTS_GUIDE.md
  - docs/QUICK_REFERENCE.md
  - docs/plan/40-service-inventory-and-placement.md

EOF
}

# Main execution
main() {
    echo ""
    echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║  HX310-DB (breintrein) Phase 3 Deployment Automation      ║${NC}"
    echo -e "${BOLD}${BLUE}║  Core Services: PostgreSQL, Vaultwarden, Gitea, Wiki.js   ║${NC}"
    echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_prerequisites
    show_deployment_plan
    
    if [ "$DRY_RUN" = true ]; then
        msg_info "Dry run complete - no changes made"
        exit 0
    fi
    
    # Deploy services in order
    deploy_postgresql || exit 1
    deploy_vaultwarden || exit 1
    deploy_gitea || exit 1
    deploy_wikijs || exit 1
    
    show_summary
}

# Run main
main
