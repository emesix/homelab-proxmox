#!/bin/bash
# Automated cluster join for all worker nodes

MASTER_IP="192.168.10.11"
PASSWORD="${PASSWORD:?Set PASSWORD env var to the SSH password for root on the nodes}"

NODES=(
    "192.168.10.12:pve-hx310-db"
    "192.168.10.13:pve-hx310-arr"
    "192.168.10.14:pve-5700g"
    "192.168.10.15:pve-8845hs"
    "192.168.10.16:pve-x2686-x2"
)

echo "=== Joining nodes to homelab-cluster ==="
echo ""

SUCCESS=0
ALREADY=0
FAILED=0

for node_info in "${NODES[@]}"; do
    IFS=':' read -r ip name <<< "$node_info"
    
    echo "=== Processing $name ($ip) ==="
    
    # Check if already in cluster
    if ssh root@$ip "pvecm status" 2>&1 | grep -q "Cluster name:"; then
        echo "✓ Already in cluster"
        ((ALREADY++))
        echo ""
        continue
    fi
    
    echo "Creating expect script on $name..."
    
    # Create expect script on the remote node
    ssh root@$ip "cat > /tmp/join-cluster.exp" <<'EXPECTEOF'
#!/usr/bin/expect -f
set timeout 60
set master [lindex $argv 0]
set password [lindex $argv 1]

spawn pvecm add $master

expect {
    "Are you sure you want to continue connecting (yes/no)?" {
        send "yes\r"
        exp_continue
    }
    "password:" {
        send "$password\r"
        exp_continue
    }
    "successfully" {
        puts "Join successful"
        exit 0
    }
    timeout {
        puts "Timeout waiting for response"
        exit 1
    }
    eof {
        exit 0
    }
}
EXPECTEOF
    
    echo "Running cluster join on $name..."
    if ssh root@$ip "chmod +x /tmp/join-cluster.exp && /tmp/join-cluster.exp '$MASTER_IP' '$PASSWORD' 2>&1"; then
        # Verify it worked
        sleep 3
        if ssh root@$ip "pvecm status" 2>&1 | grep -q "Cluster name:"; then
            echo "✓ $name successfully joined cluster"
            ((SUCCESS++))
        else
            echo "⚠ Script ran but node not in cluster"
            ((FAILED++))
        fi
    else
        echo "✗ Failed to join $name"
        ((FAILED++))
    fi
    
    # Cleanup
    ssh root@$ip "rm -f /tmp/join-cluster.exp" 2>/dev/null
    echo ""
done

echo "=== Summary ==="
echo "Successfully joined: $SUCCESS"
echo "Already in cluster: $ALREADY"
echo "Failed: $FAILED"
echo ""

# Final verification
echo "=== Cluster Status ==="
ssh root@$MASTER_IP "pvecm nodes"
