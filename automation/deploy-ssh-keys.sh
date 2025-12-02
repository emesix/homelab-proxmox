#!/bin/bash
# Deploy SSH keys to all Proxmox nodes using sshpass

# Don't exit on errors - we want to try all nodes

# Staging password
PASSWORD="${PASSWORD:?Set PASSWORD env var to the SSH password for root on the nodes}"

# Your SSH public key
SSH_PUB_KEY=$(cat ~/.ssh/id_ed25519.pub)

# Node list
NODES=(
    "192.168.10.11:pve-qotom01"
    "192.168.10.12:pve-hx310-db"
    "192.168.10.13:pve-hx310-arr"
    "192.168.10.14:pve-5700g"
    "192.168.10.15:pve-8845hs"
    "192.168.10.16:pve-x2686-x2"
)

echo "=== Deploying SSH keys to all Proxmox nodes ==="
echo ""
echo "Public key to install:"
echo "$SSH_PUB_KEY"
echo ""

SUCCESS=0
FAILED=0

for node_info in "${NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    
    echo "--- Processing $name ($ip) ---"
    
    # First test if we can connect
    if sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@$ip "echo 'Connection OK'" &>/dev/null; then
        echo "✓ Connection successful"
        
        # Add the key
        if sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$ip "echo '$SSH_PUB_KEY' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" 2>&1; then
            echo "✓ Key added to $name"
            
            # Verify passwordless access works
            sleep 1
            if ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no root@$ip "hostname" &>/dev/null; then
                echo "✓ Passwordless access verified"
                ((SUCCESS++))
            else
                echo "⚠ Key added but passwordless not working yet (may need to retry)"
                ((FAILED++))
            fi
        else
            echo "✗ Failed to add key"
            ((FAILED++))
        fi
    else
        echo "✗ Cannot connect to $name - check network/password"
        ((FAILED++))
    fi
    echo ""
done

echo "=== Summary ==="
echo "Successful: $SUCCESS"
echo "Failed: $FAILED"
echo ""

echo "=== Final Verification ==="
echo ""

ALL_OK=true
for node_info in "${NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    
    echo -n "$name ($ip): "
    if result=$(ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no root@$ip "hostname" 2>&1); then
        echo "✓ $result"
    else
        echo "✗ No passwordless access"
        ALL_OK=false
    fi
done

echo ""
if $ALL_OK; then
    echo "✓ All nodes configured successfully!"
    exit 0
else
    echo "⚠ Some nodes need attention"
    exit 1
fi
