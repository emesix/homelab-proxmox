# Qotom PCI Passthrough Setup

## Overview
Configure PCI passthrough on Qotom (192.168.10.11) to allow OPNsense VM direct access to network cards.

## Host Information
- **Hostname**: pve-qotom (TBC)
- **Management IP**: 192.168.10.11 (staging) / 10.10.200.10 (production)
- **CPU**: Intel Atom C3758R
- **RAM**: 64 GB
- **Purpose**: Network cards for OPNsense VM

## Prerequisites Checklist
- [ ] Verify CPU supports VT-d (Intel virtualization)
- [ ] Enable VT-d in BIOS/UEFI
- [ ] Identify network card PCI addresses
- [ ] Verify both network cards are functional
- [ ] Take backup of working configuration

## Step 1: Verify Network Cards

### List All Network Interfaces
```bash
ip link show
```

### Check PCI Network Devices
```bash
lspci | grep -i ethernet
lspci | grep -i network
```

### Get Detailed PCI Information
```bash
lspci -nnk | grep -A 3 -i 'ethernet\|network'
```

### Check Current Network Configuration
```bash
# Show interface status
ip addr show

# Test connectivity on each interface
ip link set dev <interface> up
ping -I <interface> -c 4 8.8.8.8
```

### Expected Interfaces on Qotom
Based on your hardware:
- **eno1**: Onboard NIC (keep for management)
- **enp8s0**: PCIe NIC #1 (pass to OPNsense)
- **enpXs0**: PCIe NIC #2 (pass to OPNsense)

## Safe Configuration Strategy

**IMPORTANT**: Follow this sequence to avoid losing management access:

### Phase 1: Setup Temporary Management on eno1
```bash
# Bring up eno1 with temporary IP
ip addr add 192.168.10.12/24 dev eno1
ip link set eno1 up
ip route add default via 192.168.10.1 dev eno1

# Test connectivity
ping -c 4 -I eno1 8.8.8.8
```

### Phase 2: Reconnect via eno1
- Disconnect from current session
- Reconnect via: `ssh root@192.168.10.12`
- Verify you're on eno1: `ip addr show eno1`

### Phase 3: Configure PCI Passthrough
Now safe to configure passthrough for enp8s0 and enpXs0 (Steps 2-5 below)

### Phase 4: Verify enp8s0 and Configure eno1 Permanently
After passthrough is working:
```bash
# Make eno1 permanent management interface
nano /etc/network/interfaces
```

Add:
```
auto eno1
iface eno1 inet static
    address 192.168.10.11/24
    gateway 192.168.10.1
```

### Phase 5: Test and Finalize
```bash
# Restart networking
systemctl restart networking

# Or reboot to verify persistent config
reboot
```

## Step 2: Enable IOMMU Support

### Edit GRUB Configuration
```bash
nano /etc/default/grub
```

Find the line starting with `GRUB_CMDLINE_LINUX_DEFAULT` and add Intel IOMMU parameters:

**For Intel CPUs (Atom C3758R):**
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
```

### Update GRUB and Reboot
```bash
update-grub
reboot
```

### Verify IOMMU is Enabled (after reboot)
```bash
dmesg | grep -e DMAR -e IOMMU
```

Expected output should show IOMMU enabled messages.

## Step 3: Load VFIO Modules

### Add Required Modules
```bash
nano /etc/modules
```

Add these lines:
```
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```

### Update Initramfs
```bash
update-initramfs -u -k all
reboot
```

### Verify Modules Loaded (after reboot)
```bash
lsmod | grep vfio
```

## Step 4: Identify Network Card PCI IDs

### List PCI Devices with IOMMU Groups
```bash
for d in /sys/kernel/iommu_groups/*/devices/*; do 
  n=${d#*/iommu_groups/*}; n=${n%%/*}
  printf 'IOMMU Group %s ' "$n"
  lspci -nns "${d##*/}"
done | grep -i 'ethernet\|network'
```

### Note the PCI Address and Vendor:Device ID
Example output:
```
IOMMU Group 1 00:14.0 Ethernet controller [0200]: Intel Corporation ... [8086:15b8]
IOMMU Group 2 00:15.0 Ethernet controller [0200]: Intel Corporation ... [8086:15b8]
```

Note down:
- PCI addresses (e.g., `00:14.0`, `00:15.0`)
- Vendor:Device IDs (e.g., `8086:15b8`)
- IOMMU group numbers

## Step 5: Blacklist Network Drivers (if needed)

**IMPORTANT**: Only bind the PCIe NICs (enp8s0, enpXs0) to VFIO. Leave eno1 for Proxmox management!

### Identify Current Driver for PCIe NICs
```bash
lspci -k | grep -A 3 -i 'ethernet\|network'
```

Look for "Kernel driver in use" line for enp8s0 and enpXs0 only.

### Get Vendor:Device IDs for PCIe NICs Only
```bash
# Get PCI address for enp8s0
ls -l /sys/class/net/enp8s0 | grep -o '[0-9a-f:]\{7\}'

# Get vendor:device ID
lspci -n -s <pci_address>

# Repeat for enpXs0
```

### Bind PCIe NICs to VFIO (NOT eno1)
```bash
nano /etc/modprobe.d/vfio.conf
```

Add (replace with ONLY the PCIe NIC vendor:device IDs):
```
# Example - replace with actual IDs from enp8s0 and enpXs0
# DO NOT include eno1's ID here!
options vfio-pci ids=8086:15b8,8086:15b9
```

### Optional: Blacklist Driver (only if needed)
If the same driver is used for all NICs, you may need to unbind specific devices instead:
```bash
# Unbind specific PCI device from driver
echo "0000:08:00.0" > /sys/bus/pci/drivers/igb/unbind
echo "0000:08:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
```

### Update and Reboot
```bash
update-initramfs -u -k all
reboot
```

### Verify VFIO Binding (after reboot)
```bash
lspci -k | grep -A 3 -i 'ethernet\|network'
```

Should show "Kernel driver in use: vfio-pci"

## Step 6: Pass Network Cards to OPNsense VM

### Via Proxmox Web UI
1. Select the OPNsense VM
2. Go to **Hardware**
3. Click **Add → PCI Device**
4. Select the network card from dropdown
5. Check **All Functions** (if applicable)
6. Check **Primary GPU** (only if needed)
7. Check **PCI-Express** (recommended)
8. Click **Add**
9. Repeat for second network card

### Via CLI
```bash
# Add first NIC (replace 100 with your VM ID and PCI address)
qm set 100 -hostpci0 00:14.0,pcie=1

# Add second NIC
qm set 100 -hostpci1 00:15.0,pcie=1
```

### Verify Configuration
```bash
qm config 100 | grep hostpci
```

## Step 7: Configure OPNsense

After starting the VM:

1. OPNsense should detect the passed-through NICs
2. Assign interfaces:
   - WAN: First NIC
   - LAN: Second NIC (or vice versa based on your setup)
3. Configure IP addresses per your network plan

## Troubleshooting

### IOMMU Not Working
```bash
# Check BIOS settings - VT-d must be enabled
dmesg | grep -i iommu

# Verify CPU supports VT-d
cat /proc/cpuinfo | grep -E "vmx|svm"
```

### PCI Device Not Available
```bash
# Check IOMMU groups
ls /sys/kernel/iommu_groups/

# Verify device is bound to vfio-pci
lspci -k -s 00:14.0
```

### VM Won't Start After Adding PCI Device
```bash
# Check VM logs
qm showcmd 100
journalctl -u pve-cluster -f

# Try with PCI-Express disabled
qm set 100 -hostpci0 00:14.0,pcie=0
```

### Network Card Not Visible in OPNsense
```bash
# Inside OPNsense VM
pciconf -lv | grep -i ethernet

# If not visible, check IOMMU groups
# All devices in same IOMMU group must be passed through together
```

## Verification Checklist
- [ ] IOMMU enabled in kernel
- [ ] VFIO modules loaded
- [ ] Network cards bound to vfio-pci
- [ ] PCI devices added to VM configuration
- [ ] VM starts successfully
- [ ] OPNsense detects network interfaces
- [ ] Both NICs functional in OPNsense
- [ ] Proxmox host still accessible via management interface

## Network Card Testing in OPNsense

After passthrough:
```bash
# List interfaces
ifconfig -a

# Test WAN connectivity
ping -c 4 8.8.8.8

# Test LAN connectivity
ping -c 4 10.10.200.1
```

## Rollback Plan

If something goes wrong:

1. Remove PCI devices from VM:
   ```bash
   qm set 100 -delete hostpci0
   qm set 100 -delete hostpci1
   ```

2. Remove VFIO configuration:
   ```bash
   rm /etc/modprobe.d/vfio.conf
   rm /etc/modprobe.d/pve-blacklist.conf
   ```

3. Update initramfs and reboot:
   ```bash
   update-initramfs -u -k all
   reboot
   ```

## Related Documentation
- `docs/NETWORK-ARCHITECTURE.md` - Network VLAN design
- `docs/PROXMOX_API_ACCESS.md` - API for automation
- `hosts/qotom-lan-mgmt.md` - Qotom hardware specs

## Notes
- Document actual PCI addresses after running discovery commands
- Update this guide with specific vendor:device IDs found
- Consider reserving one NIC for Proxmox management if needed
- Test failover scenarios before production deployment
