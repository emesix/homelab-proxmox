# Runbook-002: OPNsense Staging to Production Cutover

## Purpose

Safely transition from:

- Old router (current internet gateway)
- to the new OPNsense router, which currently runs in staging behind the old router.

The goal is to minimise downtime and ensure a clear rollback path.

## High-Level Steps

1. Confirm new OPNsense staging setup works.
2. Export and safely store OPNsense configuration.
3. Schedule a maintenance window (even if only informal).
4. Move Ziggo modem / WAN connection to the new OPNsense.
5. Validate connectivity for key devices.
6. Decommission or park the old router.

## Detailed Steps

### 1. Pre-flight Checks

- Ensure the new OPNsense:
  - Has the correct LAN config (`10.10.0.1/16` staging or early VLAN setup).
  - Can reach the internet through the old router.
  - Can resolve DNS and perform package updates.
- Ensure all new Proxmox hosts and key infra devices are reachable via the new OPNsense LAN.

### 2. Backup OPNsense Configuration

- From the OPNsense GUI:
  - Export the full configuration.
  - Store it in:
    - Git (with sensitive parts redacted or encrypted).
    - NAS (encrypted if needed).

### 3. Maintenance Window

- Pick a low-impact time.
- Inform anyone using the network that:
  - internet access may be briefly interrupted.

### 4. Physical Rewiring

- Disconnect Ziggo modem WAN from the old router.
- Connect Ziggo modem WAN to the new OPNsense WAN port.
- Power-cycle the modem if required by the ISP.

### 5. Configure WAN on New OPNsense

- Set up WAN interface for DHCP or static IP as required by Ziggo.
- Confirm:
  - OPNsense gets a WAN IP.
  - outbound internet works from OPNsense shell (e.g. `ping 8.8.8.8`).

### 6. Validate LAN Connectivity

- From a client in the staging LAN:
  - Confirm it receives an IP (from the new OPNsense DHCP, if used).
  - Confirm internet access works.
- From a Proxmox host:
  - Confirm:
    - name resolution,
    - `apt update` works (where applicable).

### 7. Rollback Plan

If issues arise:

- Disconnect WAN from new OPNsense.
- Reconnect WAN to old router.
- Power-cycle modem if necessary.
- Resume internet from old router and troubleshoot offline.

## Notes

- This runbook is intentionally simple; advanced VLAN/DMZ rules can still be added later.
- Treat the first cutover as a learning exercise – keep the firewall rules permissive at first, then tighten them once basic connectivity is proven.
