#!/bin/bash
# Deploy Gitea LXC Container (CT103) on HX310-DB
# Git server with PostgreSQL backend

set -e

PVE_NODE="pve-hx310-db"
CT_ID=103
HOSTNAME="codekroeg"
IP="192.168.10.22/16"
GW="192.168.10.1"
TEMPLATE="debian-12-standard_12.12-1_amd64.tar.zst"
CORES=1
RAM=2048
SWAP=1024
DISK=20
STORAGE="local-zfs"
PASSWORD="NikonD90"

echo "=== Gitea Container Deployment Script ==="
echo "Target: $PVE_NODE"
echo "CT ID: $CT_ID"
echo "IP: $IP"
echo ""

# Create container
echo "Creating container..."
pct create $CT_ID local:vztmpl/$TEMPLATE \
  --hostname $HOSTNAME \
  --cores $CORES \
  --memory $RAM \
  --swap $SWAP \
  --rootfs $STORAGE:$DISK \
  --net0 name=eth0,bridge=vmbr0,ip=$IP,gw=$GW \
  --nameserver 8.8.8.8 \
  --searchdomain internal \
  --features nesting=0 \
  --unprivileged 1 \
  --password="$PASSWORD" \
  --start 1

echo "✓ Container created, waiting for boot..."
sleep 20

# Install dependencies and Gitea
echo "Installing Gitea dependencies..."
pct exec $CT_ID -- bash -c "
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y \
    git \
    curl \
    wget \
    sqlite3 \
    postgresql-client \
    ca-certificates
  
  # Create git user
  adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
  
  # Create directories
  mkdir -p /var/lib/gitea/{custom,data,log}
  mkdir -p /etc/gitea
  chown -R git:git /var/lib/gitea
  chown root:git /etc/gitea
  chmod 750 /etc/gitea
"

echo "✓ Dependencies installed"
echo ""

# Download and install Gitea
echo "Downloading Gitea..."
pct exec $CT_ID -- bash -c "
  # Get latest version
  GITEA_VERSION=\$(curl -s https://api.github.com/repos/go-gitea/gitea/releases/latest | grep tag_name | cut -d '\"' -f 4 | sed 's/v//')
  
  # Download Gitea binary
  wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/\${GITEA_VERSION}/gitea-\${GITEA_VERSION}-linux-amd64
  chmod +x /usr/local/bin/gitea
  
  echo \"Gitea version: \${GITEA_VERSION}\"
"

echo "✓ Gitea binary installed"
echo ""

# Create systemd service
echo "Creating systemd service..."
pct exec $CT_ID -- bash -c "
cat > /etc/systemd/system/gitea.service <<'EOF'
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target

[Service]
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
"

echo "✓ Systemd service created"
echo ""

echo "✅ Gitea container (CT $CT_ID) base deployment complete!"
echo ""
echo "Next steps:"
echo "1. Mount datastore/gitea ZFS dataset to container"
echo "2. Create Gitea configuration (app.ini) with PostgreSQL"
echo "3. Start Gitea service"
echo "4. Complete web-based setup wizard"
echo "5. Mirror GitHub repository"
echo ""
echo "Access: ssh root@192.168.10.22 (password: $PASSWORD)"
