#!/bin/bash
# Push SSH key to all Proxmox nodes
# Since nodes already have .ssh directory prepared, this should work smoothly

set -e

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

echo "=== Pushing SSH key to all Proxmox nodes ==="
echo ""
echo "Public key to install:"
echo "$SSH_PUB_KEY"
echo ""

for node_info in "${NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    
    echo "--- Processing $name ($ip) ---"
    
    # Use sshpass if available, otherwise prompt for password
    if ssh root@$ip "echo '$SSH_PUB_KEY' >> ~/.ssh/authorized_keys" 2>&1; then
        echo "✓ Key added to $name"
        
        # Verify passwordless access works
        if ssh -o BatchMode=yes -o ConnectTimeout=3 root@$ip "echo OK" &>/dev/null; then
            echo "✓ Passwordless access verified for $name"
        else
            echo "⚠ Key added but passwordless access not working yet for $name"
        fi
    else
        echo "✗ Failed to add key to $name"
    fi
    echo ""
done

echo "=== Verification ==="
echo ""

for node_info in "${NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    
    if result=$(ssh -o BatchMode=yes -o ConnectTimeout=3 root@$ip "hostname" 2>&1); then
        echo "✓ $name ($ip): $result"
    else
        echo "✗ $name ($ip): Failed"
    fi
done

echo ""
echo "Done!"
