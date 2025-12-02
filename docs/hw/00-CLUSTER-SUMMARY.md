# Proxmox Homelab Cluster Summary

**Generated:** 2025-11-30  
**Cluster Name:** homelab-cluster  
**Status:** Quorate (6/6 nodes online)

## Cluster Information

```
Name:             homelab-cluster
Config Version:   6
Transport:        knet
Secure auth:      on
Nodes:            6
Quorum:           4/6 required
Status:           Quorate (healthy)
```

## Cluster Nodes

| Node ID | Hostname | IP Address | Role | Status |
|---------|----------|------------|------|--------|
| 1 | pve-qotom01 | 192.168.10.11 | Master | Online |
| 2 | pve-hx310-db | 192.168.10.12 | Worker | Online |
| 3 | pve-hx310-arr | 192.168.10.13 | Worker | Online |
| 4 | pve-5700g | 192.168.10.14 | Worker | Online |
| 5 | pve-8845hs | 192.168.10.15 | Worker | Online |
| 6 | pve-x2686-x2 | 192.168.10.16 | Worker | Online |

## Node Roles per Documentation

| Hostname | Dutch Nickname | Primary Role | Services |
|----------|----------------|--------------|----------|
| pve-qotom01 | vuurbuur | LAN Management | OPNsense, Netboot, WiFi mgmt |
| pve-hx310-db | breintrein | Core Services | PostgreSQL, Vaultwarden, Wiki.js, Gitea |
| pve-hx310-arr | downloadboef | Media Automation | *ARR stack, downloaders |
| pve-5700g | klusbus | Docker Worker | Heavy Docker workloads |
| pve-8845hs | hoofdstuk | AI Controller | OpenWebUI, AI orchestration |
| pve-x2686-x2 | denkdoos | AI Worker | GPU compute (dual A770) |

## Network Configuration

**Current Network:** 192.168.10.0/24 (staging)  
**Domain:** internal

### Node IP Assignments

```
192.168.10.11 - pve-qotom01.internal   (Master/Management)
192.168.10.12 - pve-hx310-db.internal  (Core Services)
192.168.10.13 - pve-hx310-arr.internal (Media/ARR)
192.168.10.14 - pve-5700g.internal     (Docker)
192.168.10.15 - pve-8845hs.internal    (AI Controller)
192.168.10.16 - pve-x2686-x2.internal  (AI Worker)
192.168.20.11 - nas-main.internal      (Storage/NAS)
```

## Access Configuration

- **SSH:** Passwordless SSH configured from control machine
- **Cluster:** All nodes joined to homelab-cluster
- **Authentication:** Common staging password configured (see password manager)
- **Admin User:** root (to be supplemented with vincent@pve)

## Hardware Reports

Individual hardware reports for each node are available in this directory:

- [pve-qotom01-hardware-report.md](./pve-qotom01-hardware-report.md)
- [pve-hx310-db-hardware-report.md](./pve-hx310-db-hardware-report.md)
- [pve-hx310-arr-hardware-report.md](./pve-hx310-arr-hardware-report.md)
- [pve-5700g-hardware-report.md](./pve-5700g-hardware-report.md)
- [pve-8845hs-hardware-report.md](./pve-8845hs-hardware-report.md)
- [pve-x2686-x2-hardware-report.md](./pve-x2686-x2-hardware-report.md)

## Current Phase Status

✅ **Phase 1:** Discovery & Validation - COMPLETE  
✅ **Phase 3:** Proxmox Cluster Setup - COMPLETE  
✅ **SSH Access:** Passwordless access configured - COMPLETE  

### Next Steps

- [ ] Phase 4: User & Permissions Setup (create vincent@pve user)
- [ ] Phase 5: Host Standardization (repository config, base packages)
- [ ] Phase 6: Core Services Deployment (PostgreSQL, Vaultwarden, Wiki.js, Gitea)
- [ ] Phase 7: OPNsense Deployment
- [ ] Phase 8: Network transition (optional - staying on 192.168.10.x for now)
- [ ] Phase 9: VLAN Implementation (future)

## Notes

- Cluster created: 2025-11-30
- All nodes successfully joined
- Enterprise repositories disabled on nodes with issues
- Expect package installed on all worker nodes for automation
- Hardware inventory completed and documented

---

For detailed hardware specifications, MAC addresses, storage devices, and configuration details, see individual node hardware reports.
