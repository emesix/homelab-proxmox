# Hardware Documentation

This directory contains comprehensive hardware reports for all Proxmox nodes in the homelab cluster.

## Contents

- **[00-CLUSTER-SUMMARY.md](./00-CLUSTER-SUMMARY.md)** - Overview of the entire cluster
- Individual node hardware reports (see below)

## Node Hardware Reports

Each report includes:
- System information (hostname, OS, kernel, uptime)
- CPU details (model, cores, threads, frequencies)
- Memory information (capacity, speed, type, manufacturer)
- **Network interfaces with MAC addresses** (all interfaces, connected and disconnected)
- **Storage devices** (mounted, unmounted, and unpartitioned disks)
- SMART status for all drives
- PCI devices (network cards, GPUs, controllers)
- USB devices
- ZFS pools (if configured)
- LVM information (if configured)
- Proxmox VE configuration
- Hardware sensors
- DMI/SMBIOS information (manufacturer, serial numbers, BIOS info)

### Available Reports

1. **pve-qotom01** (vuurbuur) - Master node / LAN management
2. **pve-hx310-db** (breintrein) - Core services / Database node
3. **pve-hx310-arr** (downloadboef) - Media automation
4. **pve-5700g** (klusbus) - Docker worker
5. **pve-8845hs** (hoofdstuk) - AI controller
6. **pve-x2686-x2** (denkdoos) - AI worker / GPU compute

## Updating Reports

To regenerate hardware reports for all nodes:

```bash
cd /home/emesix/Proxmox-Based-Homelab
./automation/collect-hardware-info.sh <node_ip> docs/hw
```

Or collect all at once:

```bash
for ip in 192.168.10.{11..16}; do
    ./automation/collect-hardware-info.sh $ip docs/hw
done
```

## Report Generation

Reports are generated using the `automation/collect-hardware-info.sh` script which:
- Connects to each node via SSH
- Collects comprehensive hardware and configuration data
- Formats output as Markdown for easy reading
- Includes all MAC addresses and storage devices

**Last Updated:** 2025-11-30
