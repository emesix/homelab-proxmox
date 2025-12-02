#!/bin/bash
# Setup Proxmox cluster with pve-qotom01 as master

# Cluster configuration
CLUSTER_NAME="homelab-cluster"
MASTER_NODE="192.168.10.11"
MASTER_HOSTNAME="pve-qotom01"

WORKER_NODES=(
    "192.168.10.12:pve-hx310-db"
    "192.168.10.13:pve-hx310-arr"
    "192.168.10.14:pve-5700g"
    "192.168.10.15:pve-8845hs"
    "192.168.10.16:pve-x2686-x2"
)

echo "=== Proxmox Cluster Setup ==="
echo "Master node: $MASTER_HOSTNAME ($MASTER_NODE)"
echo "Cluster name: $CLUSTER_NAME"
echo ""

# Step 1: Fix hostname on master node if needed
echo "--- Step 1: Checking master node hostname ---"
CURRENT_HOSTNAME=$(ssh root@$MASTER_NODE "hostname")
echo "Current hostname: $CURRENT_HOSTNAME"

if [ "$CURRENT_HOSTNAME" != "$MASTER_HOSTNAME" ]; then
    echo "⚠ Hostname mismatch - fixing..."
    ssh root@$MASTER_NODE "hostnamectl set-hostname $MASTER_HOSTNAME && echo '✓ Hostname set to $MASTER_HOSTNAME'"
    echo "Waiting for hostname to propagate..."
    sleep 3
else
    echo "✓ Hostname is correct"
fi
echo ""

# Step 2: Fix hostname on worker node 16 if needed
echo "--- Step 2: Checking pve-x2686-x2 hostname ---"
CURRENT_X2686=$(ssh root@192.168.10.16 "hostname")
echo "Current hostname: $CURRENT_X2686"

if [ "$CURRENT_X2686" != "pve-x2686-x2" ]; then
    echo "⚠ Hostname mismatch - fixing..."
    ssh root@192.168.10.16 "hostnamectl set-hostname pve-x2686-x2 && echo '✓ Hostname set to pve-x2686-x2'"
    echo "Waiting for hostname to propagate..."
    sleep 3
else
    echo "✓ Hostname is correct"
fi
echo ""

# Step 3: Check if cluster already exists
echo "--- Step 3: Checking if cluster exists ---"
if ssh root@$MASTER_NODE "pvecm status" 2>&1 | grep -q "Cluster name:"; then
    echo "⚠ Cluster already exists!"
    ssh root@$MASTER_NODE "pvecm status"
    echo ""
    echo "Do you want to continue adding nodes? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
    CLUSTER_EXISTS=true
else
    echo "✓ No cluster exists yet"
    CLUSTER_EXISTS=false
fi
echo ""

# Step 4: Create cluster on master node
if [ "$CLUSTER_EXISTS" = false ]; then
    echo "--- Step 4: Creating cluster on master node ---"
    echo "Creating cluster '$CLUSTER_NAME' on $MASTER_HOSTNAME..."
    
    if ssh root@$MASTER_NODE "pvecm create $CLUSTER_NAME"; then
        echo "✓ Cluster created successfully"
        sleep 5  # Wait for cluster to initialize
        
        # Verify cluster
        echo ""
        echo "Cluster status:"
        ssh root@$MASTER_NODE "pvecm status"
    else
        echo "✗ Failed to create cluster"
        exit 1
    fi
    echo ""
else
    echo "--- Step 4: Skipping cluster creation (already exists) ---"
    echo ""
fi

# Step 5: Join worker nodes to cluster
echo "--- Step 5: Adding worker nodes to cluster ---"
echo ""

for node_info in "${WORKER_NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    
    echo "=== Processing $name ($ip) ==="
    
    # Check if already in cluster
    if ssh root@$ip "pvecm status" 2>&1 | grep -q "Cluster name:"; then
        echo "✓ Already in cluster, skipping"
        echo ""
        continue
    fi
    
    echo "Adding $name to cluster..."
    
    # Join cluster
    if ssh root@$ip "pvecm add $MASTER_NODE" <<EOF
yes
EOF
    then
        echo "✓ $name successfully joined cluster"
        sleep 3
    else
        echo "✗ Failed to add $name to cluster"
        echo "⚠ You may need to add this node manually"
    fi
    echo ""
done

# Step 6: Final verification
echo "=== Final Cluster Status ==="
echo ""
ssh root@$MASTER_NODE "pvecm status"
echo ""
ssh root@$MASTER_NODE "pvecm nodes"
echo ""

echo "=== Cluster setup complete! ==="
echo ""
echo "You can now access the cluster at:"
echo "  https://$MASTER_NODE:8006"
echo "  or any other node's IP"
echo ""
echo "All nodes should be visible in the Datacenter view."
