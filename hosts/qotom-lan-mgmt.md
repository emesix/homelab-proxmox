# Qotom 1U – LAN Management Host

## Hardware Overview

- Model: Qotom 1U (C3758R)
- CPU: Intel Atom C3758R
- RAM: 64 GB
- Storage:
  - 2× NVMe SSD (exact layout to be documented)
- Primary role:
  - OPNsense VM host (router/firewall).
  - Supporting LXC/VMs for:
    - Netboot.xyz
    - OpenWISP
    - Notifiarr (optional)
    - CUPS (printer server)
    - Configuration backup services.

## Proxmox Node

- Node name: `pve-qotom` (placeholder, adjust if needed).
- Management IP (staging and production, in `10.10.200.0/24` block):
  - `10.10.200.10`

## Planned VMs / LXCs

- `vm-opnsense`:
  - PCI passthrough of Intel NICs and SFP if required.
  - Primary router/firewall.
- `lxc-netbootxyz`
- `lxc-openwisp`
- `lxc-notifiarr` (if not placed elsewhere)
- `lxc-cups`
- `lxc-configbackup`

Further details to be refined in dedicated service and Proxmox docs.
