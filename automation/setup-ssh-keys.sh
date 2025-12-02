#!/bin/bash
# Setup passwordless SSH access to all Proxmox nodes
# This script will copy your SSH public key to each node

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Proxmox node IPs
NODES=(
    "192.168.10.11:pve-qotom01"
    "192.168.10.12:pve-hx310-db"
    "192.168.10.13:pve-hx310-arr"
    "192.168.10.14:pve-5700g"
    "192.168.10.15:pve-8845hs"
    "192.168.10.16:pve-x2686-x2"
)

# SSH key to use
SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY="${SSH_KEY}.pub"

# Check if key exists
if [ ! -f "$SSH_PUB_KEY" ]; then
    echo -e "${RED}Error: SSH public key not found at $SSH_PUB_KEY${NC}"
    exit 1
fi

echo -e "${GREEN}SSH Public Key to install:${NC}"
cat "$SSH_PUB_KEY"
echo ""
echo -e "${YELLOW}This script will install the above key on all Proxmox nodes${NC}"
echo ""

# Test connectivity and passwordless access
echo "=== Testing connectivity and current access ===" 
for node_info in "${NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    echo -n "Testing $name ($ip): "
    
    # Test if passwordless access already works
    if ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=accept-new root@$ip "echo OK" &>/dev/null; then
        echo -e "${GREEN}✓ Passwordless access already configured${NC}"
    else
        echo -e "${YELLOW}✗ Needs configuration${NC}"
    fi
done

echo ""
echo "=== Installing SSH keys ===" 
echo "You will be prompted for the root password for each node that needs it."
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0
ALREADY_COUNT=0

for node_info in "${NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    
    echo -e "\n${YELLOW}--- Processing $name ($ip) ---${NC}"
    
    # Check if already configured
    if ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=accept-new root@$ip "echo OK" &>/dev/null; then
        echo -e "${GREEN}Already configured, skipping${NC}"
        ((ALREADY_COUNT++))
        continue
    fi
    
    # Try to copy the key
    if ssh-copy-id -i "$SSH_PUB_KEY" -o PreferredAuthentications=password root@$ip 2>&1; then
        echo -e "${GREEN}✓ Key installed successfully${NC}"
        
        # Verify it works
        if ssh -o BatchMode=yes -o ConnectTimeout=3 root@$ip "echo OK" &>/dev/null; then
            echo -e "${GREEN}✓ Verified passwordless access${NC}"
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}✗ Warning: Key installed but passwordless access not working${NC}"
            ((FAIL_COUNT++))
        fi
    else
        echo -e "${RED}✗ Failed to install key${NC}"
        ((FAIL_COUNT++))
    fi
done

# Summary
echo ""
echo "=== Summary ===" 
echo -e "${GREEN}Successfully configured: $SUCCESS_COUNT${NC}"
echo -e "${YELLOW}Already configured: $ALREADY_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo ""

# Final verification
echo "=== Final Verification ===" 
ALL_OK=true
for node_info in "${NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    echo -n "$name ($ip): "
    
    if RESULT=$(ssh -o BatchMode=yes -o ConnectTimeout=3 root@$ip "hostname" 2>&1); then
        echo -e "${GREEN}✓ $RESULT${NC}"
    else
        echo -e "${RED}✗ Cannot connect${NC}"
        ALL_OK=false
    fi
done

echo ""
if $ALL_OK; then
    echo -e "${GREEN}All nodes are accessible via passwordless SSH!${NC}"
    exit 0
else
    echo -e "${YELLOW}Some nodes still need manual configuration${NC}"
    exit 1
fi
