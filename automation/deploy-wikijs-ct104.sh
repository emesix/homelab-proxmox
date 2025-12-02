#!/bin/bash
# Deploy Wiki.js LXC Container (CT104) on HX310-DB
# Documentation platform with Docker backend

set -e

PVE_NODE="pve-hx310-db"
CT_ID=104
HOSTNAME="wiki-brein"
IP="192.168.10.23/16"
GW="192.168.10.1"
TEMPLATE="debian-12-standard_12.12-1_amd64.tar.zst"
CORES=1
RAM=2048
SWAP=1024
DISK=20
STORAGE="local-zfs"
PASSWORD="NikonD90"

echo "=== Wiki.js Container Deployment Script ==="
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
  --features nesting=1 \
  --unprivileged 0 \
  --password="$PASSWORD" \
  --start 1

echo "✓ Container created, waiting for boot..."
sleep 20

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
pct exec $CT_ID -- bash -c "
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  
  # Add Docker GPG key
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  
  # Add Docker repository
  echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \$(. /etc/os-release && echo \"\$VERSION_CODENAME\") stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Install Docker
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  
  # Enable and start Docker
  systemctl enable docker
  systemctl start docker
"

echo "✓ Docker installed"
echo ""

# Create Wiki.js directory
echo "Setting up Wiki.js..."
pct exec $CT_ID -- bash -c "
  mkdir -p /opt/wikijs
  chmod 755 /opt/wikijs
"

echo "✓ Wiki.js directory created"
echo ""

echo "✅ Wiki.js container (CT $CT_ID) base deployment complete!"
echo ""
echo "Next steps:"
echo "1. Create docker-compose.yml with PostgreSQL connection"
echo "2. Start Wiki.js container"
echo "3. Complete web-based setup wizard"
echo "4. Configure Git sync with Gitea"
echo ""
echo "Access: ssh root@192.168.10.23 (password: $PASSWORD)"
