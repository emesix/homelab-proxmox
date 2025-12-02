# Staging Network and VLAN Transition Plan

This document explains how to:
1. Bring all hosts online in a simple, flat **staging** network.
2. Choose IP addresses that already match the future VLAN layout.
3. Later introduce VLANs and /24 subnets without renumbering hosts.

## 1. Staging Network Design

During staging, the new OPNsense router sits **behind** the existing router.

- WAN: existing OPNsense / Ziggo modem.
- LAN (staging): `10.10.0.1/16` (mask `255.255.0.0`).

All Proxmox hosts, switches, APs, etc. receive addresses from this /16, but:
- Each host is manually assigned (or reserved via DHCP) in the **right /24 range** for its future VLAN.

Example ranges:

- `10.10.10.0/24` → future `VLAN 10` – Guest LAN.
- `10.10.20.0/24` → future `VLAN 20` – IoT (cameras, TV boxes, fans, doorbells).
- `10.10.30.0/24` → future `VLAN 30` – user LAN (laptops, desktops, phones).
- `10.10.40.0/24` → future `VLAN 40` – DMZ (BSD jails: mail, reverse proxy, VPN).
- `10.10.90.0/24` → future `VLAN 90` – VvE CCTV + recorder.
- `10.10.100.0/24` → future `VLAN 100` – backend Docker services.
- `10.10.110.0/24` → future `VLAN 110` – backend DB (Postgres, Wiki.js, Vaultwarden).
- `10.10.120.0/24` → future `VLAN 120` – backend AI (controller, vector DB).
- `10.10.130.0/24` → future `VLAN 130` – backend storage (NFS/SMB/backups).
- `10.10.200.0/24` → future `VLAN 200` – management (Proxmox GUI, switches, APs).

During staging:
- All of these live inside a single `/16` network.
- There are **no VLANs configured yet**.
- Devices can talk freely across all ranges, which keeps installation simple.

The key is **address discipline**: using future ranges now avoids renumbering later.

## 2. Host Addressing Examples

Suggested management IPs (inside `10.10.200.0/24` range):

- Qotom (LAN management / OPNsense host):
  - `10.10.200.10`
- HX310-DB (Postgres, Wiki, Vaultwarden):
  - `10.10.200.20`
- HX310-ARR (media / *ARR / Docker controller):
  - `10.10.200.21`
- CW-NAS-AMD-FP7 (AI controller):
  - `10.10.200.30`
- X99 Dual Xeon (AI worker):
  - `10.10.200.40`
- Ryzen 5700G Docker worker:
  - `10.10.200.50`
- unRAID NAS:
  - `10.10.130.10` (storage/backend) and optionally a management IP in `10.10.200.x` if desired.

These addresses are initially reachable because OPNsense LAN is `/16` (`10.10.0.1/16`).

## 3. Transition to VLANs

Once:

- All Proxmox nodes are installed and joined in a cluster.
- The new OPNsense is ready to replace the old router.
- Basic services (e.g. SSH, Proxmox GUI) are reachable reliably.

Then:

1. Move Ziggo WAN + DHCP to the **new** OPNsense (cutover event).
2. Convert the LAN from `/16` to multiple `/24` VLANs.

### 3.1. OPNsense VLAN Setup

For each logical network, create:

- A VLAN interface (e.g. `VLAN 30` on the LAN trunk).
- A corresponding `/24` subnet using the same addresses as in staging.

Example:

- `VLAN 30` – LAN-USER:
  - Interface IP: `10.10.30.1/24`
  - DHCP range: e.g. `10.10.30.50–10.10.30.200`.

- `VLAN 200` – MGMT:
  - Interface IP: `10.10.200.1/24`
  - DHCP reservations for Proxmox/infra hosts as planned above.

Initially, firewall rules can be very permissive (to mimic the old flat network), and later hardened.

### 3.2. Switch and AP Configuration

- Uplink from OPNsense to core switch becomes a **trunk**:
  - tagged VLANs: 20, 30, 40, 90, 100, 110, 120, 130, 200.
- Access ports:
  - User devices (PCs, etc.) → access VLAN 30.
  - IoT devices → access VLAN 20.
  - Management ports (switch/AP management) → access VLAN 200.

Wi-Fi APs:
- Trunk connection carrying:
  - VLAN 10 – guest SSID.
  - VLAN 20 – IoT SSID.
  - VLAN 30 – private SSID.

SSID-to-VLAN mapping is configured on the APs, but AP management IP stays in VLAN 200.

### 3.3. Host Configuration Changes

For most hosts, the only changes required are:

- Netmask: `/16` → `/24`.
- Interface connected to the right VLAN (via switch port config or Proxmox bridge).

The IP addresses themselves (e.g. `10.10.200.10` for Qotom) stay the same.

## 4. Firewall Strategy (High-Level)

Once VLANs are live, aim for:

- MGMT (VLAN 200):
  - Allowed to reach Proxmox nodes, switches, APs, routers.
  - Restricted access from other VLANs (ideally only from trusted admin devices).

- LAN-USER (VLAN 30):
  - Outbound internet allowed.
  - Access to selected internal services (reverse proxy / frontends) only.

- LAN-IOT (VLAN 20):
  - Outbound internet only if required.
  - No direct access to management, DB, AI, or NAS networks.
  - Exceptions for specific APIs (e.g. MQTT, NTP, DNS) can be whitelisted.

- BACKEND networks (100–130):
  - Internal service-to-service communication.
  - No direct access from internet or DMZ.
  - Outbound internet limited to what services actually need.

- DMZ (VLAN 40):
  - Hosts public-facing services (mail, reverse proxy, VPN).
  - DMZ services talk **inward** only to the minimal backend/frontends necessary.

## 5. Summary

- Start simple: one `/16` staging network with disciplined IP allocation.
- Use the future /24 ranges from day one so you never need mass renumbering.
- Once the environment is stable, slice the /16 into VLAN-backed /24s.
- Harden firewall rules gradually as you validate each path.
