# ADR-003: OPNsense Staging Router Behind Existing Router

## Status

Accepted

## Context

A new OPNsense-based design is being introduced which will:

- Eventually become the primary router/firewall for the homelab.
- Host VLAN-aware configuration, firewall rules, and VPN entry points.
- Support complex segmentation (frontend, backend, management, DMZ, IoT, VvE).

The existing router already provides internet connectivity and must remain intact while the new design is built and tested.

## Decision

The new OPNsense will initially be deployed as a **staging router behind the existing router**:

- WAN of the new OPNsense → LAN of the existing router.
- LAN of the new OPNsense → staging network (`10.10.0.0/16`), where all new Proxmox hosts and infrastructure live.

This allows:

- Building and testing the new design without impacting production internet access.
- Iterative refinement of VLANs, firewall rules, and service placement.
- A controlled cutover moment where:
  - Ziggo modem and DHCP are switched from the old to the new OPNsense.
  - Downtime is limited mainly to a modem reset and DHCP transition.

## Consequences

- Slightly more complexity in the interim (double NAT), but acceptable for staging.
- Greatly reduced risk of accidental lockouts or major outages during initial configuration.
- A clear path to “flip the switch” and retire the old router when ready.
