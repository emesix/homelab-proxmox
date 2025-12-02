#!/bin/bash
# Deploy PostgreSQL LXC Container (CT100) on HX310-DB
# Based on deployment plan but simplified and tested

set -e

PVE_NODE="pve-hx310-db"
CT_ID=101
HOSTNAME="pg-brein"
IP="192.168.10.20/16"
GW="192.168.10.1"
TEMPLATE="debian-12-standard_12.12-1_amd64.tar.zst"
CORES=2
RAM=8192
SWAP=2048
DISK=100
STORAGE="local-zfs"
PASSWORD="NikonD90"

echo "=== PostgreSQL Container Deployment Script ===" 
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

# Update and install PostgreSQL
echo "Installing PostgreSQL..."
pct exec $CT_ID -- bash -c "
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y postgresql postgresql-contrib
  systemctl enable postgresql
  systemctl start postgresql
"

echo "✓ PostgreSQL installed"
echo ""

# Configure PostgreSQL for remote access
echo "Configuring PostgreSQL for remote access..."
pct exec $CT_ID -- bash -c "
  # Allow connections from 192.168.10.0/16
  echo 'host    all             all             192.168.10.0/16         md5' >> /etc/postgresql/15/main/pg_hba.conf
  
  # Listen on all interfaces
  sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*'/\" /etc/postgresql/15/main/postgresql.conf
  
  # Restart PostgreSQL
  systemctl restart postgresql
"

echo "✓ Remote access configured"
echo ""

echo "✅ PostgreSQL container (CT $CT_ID) deployed successfully!"
echo ""
echo "Next steps:"
echo "1. Create databases: vaultwarden, gitea, wikijs"
echo "2. Create database users with passwords"
echo "3. Configure PostgreSQL performance tuning"
echo ""
echo "Access: ssh root@192.168.10.20 (password: $PASSWORD)"
