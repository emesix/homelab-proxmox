#!/bin/bash
# Collect comprehensive hardware information from a Proxmox node

NODE_IP="$1"
OUTPUT_DIR="$2"

if [ -z "$NODE_IP" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <node_ip> <output_dir>"
    exit 1
fi

# Get hostname
HOSTNAME=$(ssh root@$NODE_IP "hostname")
OUTPUT_FILE="$OUTPUT_DIR/${HOSTNAME}-hardware-report.md"

echo "Collecting hardware info from $HOSTNAME ($NODE_IP)..."

# Create comprehensive hardware report
ssh root@$NODE_IP 'bash -s' > "$OUTPUT_FILE" <<'REMOTE_SCRIPT'
#!/bin/bash

HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d %H:%M:%S")

cat <<EOF
# Hardware Report: $HOSTNAME
Generated: $DATE

## System Information
EOF

echo '```'
echo "Hostname: $(hostname -f)"
echo "Kernel: $(uname -r)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Uptime: $(uptime -p)"
echo "Architecture: $(uname -m)"
echo '```'

cat <<EOF

## CPU Information
EOF

echo '```'
lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core|Socket|Vendor|MHz"
echo '```'

cat <<EOF

### Detailed CPU Info
\`\`\`
EOF
cat /proc/cpuinfo | grep -E "processor|model name|cpu MHz|cache size" | head -20
echo '```'

cat <<EOF

## Memory Information
EOF

echo '```'
free -h
echo ""
echo "Memory Details:"
dmidecode -t memory 2>/dev/null | grep -E "Size|Speed|Type:|Manufacturer|Serial" | grep -v "No Module"
echo '```'

cat <<EOF

## Network Interfaces
EOF

echo '```'
ip -br addr show
echo ""
echo "=== MAC Addresses ==="
ip link show | grep -E "^[0-9]+:|link/ether" | sed 'N;s/\n/ /'
echo '```'

cat <<EOF

### Network Interface Details
\`\`\`
EOF
ip addr show
echo '```'

cat <<EOF

## Storage Devices
EOF

echo '```'
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL,SERIAL
echo '```'

cat <<EOF

### Disk Details (Unmounted/Unpartitioned)
\`\`\`
EOF
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT | grep -E "disk|part" 
echo ""
echo "=== All Block Devices ==="
fdisk -l 2>/dev/null | grep -E "Disk /dev/|Sector size|Disk model"
echo '```'

cat <<EOF

### SMART Status
\`\`\`
EOF
for disk in $(lsblk -ndo NAME | grep -E "^sd|^nvme"); do
    echo "=== /dev/$disk ==="
    smartctl -i /dev/$disk 2>/dev/null | grep -E "Model|Serial|Capacity|SMART support"
    smartctl -H /dev/$disk 2>/dev/null | grep -E "SMART overall|result:"
    echo ""
done
echo '```'

cat <<EOF

## PCI Devices
EOF

echo '```'
lspci | grep -E "Ethernet|Network|VGA|Audio|SATA|NVMe|USB"
echo '```'

cat <<EOF

### Detailed PCI Info
\`\`\`
EOF
lspci -v | grep -A 5 "Ethernet\|Network" | head -40
echo '```'

cat <<EOF

## USB Devices
EOF

echo '```'
lsusb
echo '```'

cat <<EOF

## ZFS Pools (if any)
EOF

if command -v zpool &> /dev/null; then
    echo '```'
    zpool list 2>/dev/null || echo "No ZFS pools found"
    echo ""
    zpool status 2>/dev/null || echo "No ZFS pools"
    echo '```'
else
    echo '```'
    echo "ZFS not installed"
    echo '```'
fi

cat <<EOF

## LVM Information (if any)
EOF

echo '```'
pvs 2>/dev/null || echo "No LVM physical volumes"
echo ""
vgs 2>/dev/null || echo "No LVM volume groups"
echo ""
lvs 2>/dev/null || echo "No LVM logical volumes"
echo '```'

cat <<EOF

## Proxmox VE Information
EOF

echo '```'
pveversion -v
echo '```'

cat <<EOF

### Proxmox Storage Configuration
\`\`\`
EOF
pvesm status
echo '```'

cat <<EOF

### Proxmox Network Configuration
\`\`\`
EOF
cat /etc/network/interfaces
echo '```'

cat <<EOF

## Hardware Sensors (if available)
EOF

if command -v sensors &> /dev/null; then
    echo '```'
    sensors 2>/dev/null || echo "No sensor data available"
    echo '```'
else
    echo '```'
    echo "lm-sensors not installed"
    echo '```'
fi

cat <<EOF

## DMI/SMBIOS Information
EOF

echo '```'
echo "=== System ==="
dmidecode -t system 2>/dev/null | grep -E "Manufacturer|Product|Serial|UUID"
echo ""
echo "=== BIOS ==="
dmidecode -t bios 2>/dev/null | grep -E "Vendor|Version|Release"
echo ""
echo "=== Baseboard ==="
dmidecode -t baseboard 2>/dev/null | grep -E "Manufacturer|Product|Serial"
echo '```'

cat <<EOF

---
Report generated on $DATE
EOF

REMOTE_SCRIPT

echo "✓ Report saved to: $OUTPUT_FILE"
