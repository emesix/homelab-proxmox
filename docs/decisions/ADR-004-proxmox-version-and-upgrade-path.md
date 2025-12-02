# ADR-004: Proxmox Version and Upgrade Path

## Status

Accepted (2025-11-23)

## Context

The homelab relies heavily on:

- ZFS on root and additional pools,
- PCI passthrough (especially for NICs to OPNsense),
- a heterogeneous mix of hardware (Qotom 1U, HX310, X99 dual-Xeon, etc).

Recently we attempted to install **Proxmox VE 9.0-1** with **ZFS root** and hit a
boot-time kernel panic (see `docs/incidents/20251111-proxmox9-zfs-boot-kernel-panic.md`).

At the same time:

- Proxmox VE **8.x** is known-good for:
  - ZFS,
  - NIC passthrough,
  - the current homelab layout.
- Many runbooks and plan docs in `homelab-proxmox` are already written assuming 8.x.

We need a **clear decision** on which Proxmox major version is the baseline and how
we approach upgrades.

## Decision

1. **Baseline Proxmox Version**
   - The homelab Proxmox cluster is standardised on **Proxmox VE 8.x** for now.
   - All runbooks are written and tested primarily against 8.x.

2. **Upgrade Strategy**
   - No in-place upgrade to 9.x on production nodes until:
     - the boot issue in the incident is understood and reproducible on a spare host,
     - there is at least one *successful* ZFS-root Proxmox 9.x installation on local hardware.
   - Upgrades will be done **node-by-node**, with:
     - backups verified,
     - possibility to reinstall and restore from Proxmox backups if needed.

3. **Testing Approach**
   - Use **non-critical hosts or new hardware** to:
     - install Proxmox 9.x with ZFS root,
     - test Proxmox helper scripts,
     - validate PCI passthrough behaviour.
   - Only after successful tests will we:
     - update runbooks,
     - plan a rolling upgrade for the cluster.

4. **Documentation Alignment**
   - All new runbooks and plan docs must state the **Proxmox major version** they target.
   - Where 8.x vs 9.x differ, note the differences explicitly.

## Alternatives Considered

1. **Immediate cluster-wide upgrade to Proxmox VE 9.x**
   - Pros:
     - Access to latest features.
   - Cons:
     - Boot instability on at least one host (ZFS root),
     - Higher risk of extended downtime.
   - **Rejected** until the incident is resolved.

2. **Split cluster (some nodes on 8.x, some on 9.x)**
   - Pros:
     - Early testing of 9.x in the same cluster.
   - Cons:
     - More complexity,
     - Harder to reason about bugs,
     - Risk of hidden compatibility issues.
   - **Rejected**; prefer a clean staged migration.

3. **Abandon Proxmox for another hypervisor**
   - Pros:
     - Could pick an OS with different ZFS integration, or go back to a more generic Debian/Arch + KVM stack.
   - Cons:
     - Loses all the Proxmox-specific work, helper scripts, and existing runbooks,
     - Increases cognitive load.
   - **Rejected**; Proxmox is still the preferred hypervisor.

## Consequences

- **Short term**
  - All production work assumes Proxmox VE 8.x.
  - Some plan docs will include TODOs for “9.x review”.

- **Medium term**
  - Once Proxmox 9.x is proven stable on local hardware:
    - create a dedicated runbook: *Upgrade Proxmox 8.x ZFS host to 9.x*,
    - schedule rolling upgrades with clear rollback steps.

- **Long term**
  - This ADR should be revisited once:
    - 8.x is EOL, or
    - there are compelling 9.x features that justify the migration work.

## Links

- Incident: `docs/incidents/20251111-proxmox9-zfs-boot-kernel-panic.md`
- Plan: `docs/plan/10-roadmap.md`
- Runbooks:
  - `docs/runbooks/runbook-001-proxmox-host-installation.md`
