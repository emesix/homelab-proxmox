# ADR-001: Network Segmentation and VLAN Strategy

## Status

Accepted

## Context

The homelab must support:

- Frontend user access (browsers, apps, remote access).
- Backend data and Docker traffic (NFS/SMB, API calls).
- Management of infrastructure (Proxmox, switches, APs, routers).
- DMZ services (mail, reverse proxy, VPN).
- IoT and VvE CCTV segments with different trust levels.

There is a strong desire to:

- Monitor backend behaviour for anomalies (e.g. unusual lateral movement).
- Ensure that all public-facing HTTP/HTTPS access goes via a dedicated DMZ/frontends, not directly to backend or management networks.
- Avoid renumbering the entire network later.

## Decision

1. Use a **staging network** (`10.10.0.0/16`) during initial deployment.
2. Allocate IP addresses from day one according to their **future /24 VLAN blocks**.
3. Transition to a segmented design with dedicated VLANs, including (but not limited to):

   - `VLAN 10` – Guest LAN (`10.10.10.0/24`).
   - `VLAN 20` – IoT (`10.10.20.0/24`).
   - `VLAN 30` – User LAN (`10.10.30.0/24`).
   - `VLAN 40` – DMZ BSD/jails (mail, reverse proxy, VPN) (`10.10.40.0/24`).
   - `VLAN 90` – VvE CCTV (`10.10.90.0/24`).
   - `VLAN 100–130` – Backend (Docker, DB, AI, storage) (`10.10.100–130.0/24`).
   - `VLAN 200` – Management (`10.10.200.0/24`).

4. Enforce the following security model:

   - Management is only reachable from trusted admin devices.
   - Backend networks have **no direct** exposure to the internet or DMZ.
   - All user-facing HTTP/HTTPS access flows through:
     - frontends / reverse proxies,
     - DMZ nodes as appropriate.

## Consequences

- Initial installation is simplified because everything lives in one `/16` network.
- IPs do not need to change when VLANs are introduced:
  - Only netmask and VLAN tagging are adjusted.
- Network monitoring can be focused on backend VLANs, with clear expectations about which protocols and flows are normal.
- There is a small amount of upfront planning effort (documenting VLAN IDs and IP ranges), but this is far cheaper than later renumbering.
