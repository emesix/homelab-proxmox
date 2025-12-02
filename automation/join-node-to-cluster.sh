#!/bin/bash
# Join a single node to the Proxmox cluster
# Usage: ./join-node-to-cluster.sh <node_ip> <node_name>

NODE_IP="$1"
NODE_NAME="$2"
MASTER_IP="192.168.10.11"

if [ -z "$NODE_IP" ] || [ -z "$NODE_NAME" ]; then
    echo "Usage: $0 <node_ip> <node_name>"
    echo "Example: $0 192.168.10.12 pve-hx310-db"
    exit 1
fi

echo "=== Joining $NODE_NAME ($NODE_IP) to cluster ==="
echo ""

# Check if node is already in cluster
if ssh root@$NODE_IP "pvecm status" 2>&1 | grep -q "Cluster name:"; then
    echo "✓ $NODE_NAME is already in the cluster"
    ssh root@$NODE_IP "pvecm status" | head -10
    exit 0
fi

echo "Adding $NODE_NAME to homelab-cluster..."
echo "You will need to type 'yes' when prompted for the fingerprint"
echo ""

# Run the join command interactively
ssh -t root@$NODE_IP "pvecm add $MASTER_IP"

# Check if successful
echo ""
if ssh root@$NODE_IP "pvecm status" 2>&1 | grep -q "Cluster name:"; then
    echo "✓ $NODE_NAME successfully joined the cluster!"
else
    echo "✗ Failed to join cluster. Check the output above for errors."
    exit 1
fi
