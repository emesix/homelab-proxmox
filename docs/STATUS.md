# Homelab Documentation Status (December 2025)

**Last Updated:** 2025-12-02

This document helps you navigate the homelab documentation and understand what's current vs historical.

## 📍 Current Deployment Status

**Phase:** 3 (Core Services) - Partially Complete  
**Network:** Flat 192.168.0.0/16 (VLANs planned for Phase 4)  
**Cluster:** 6 nodes, fully quorate

## 📚 Documentation Structure

### ✅ Current & Accurate

These documents reflect the **actual deployed state** as of December 2025:

- **`/docs/infra/network/2025-12-ip-plan-ACTUAL.md`** ⭐ **START HERE**
  - Current IP addressing scheme
  - Service locations
  - ZFS configuration
  - Node nicknames (bijnamen)

- **`/docs/plan/10-roadmap.md`**
  - Overall phased deployment plan
  - Current phase: Phase 3

- **`/docs/plan/40-service-inventory-and-placement.md`**
  - Which services run on which nodes
  - Includes Dutch nicknames (bijnamen)

- **`/docs/plan/50-network-layout-and-security-levels.md`**
  - Future VLAN design (Phase 4)
  - Security level model
  - Updated with 192.168.x.x scheme

- **`/docs/hw/*.md`**
  - Hardware reports for each node
  - CPU, RAM, storage specs

### ⚠️ Partially Outdated

These documents have some outdated info but are still useful:

- **`/docs/infra/hosts/proxmox-nodes.md`**
  - Hardware info: ✅ Accurate
  - IP addresses: ❌ Outdated (uses 192.168.10.x)
  - See 2025-12-ip-plan-ACTUAL.md for current IPs

### 🗄️ Historical / Deprecated

These documents are kept for reference but are outdated:

- **`/docs/infra/network/2025-11-ip-plan.md`**
  - Superseded by 2025-12-ip-plan-ACTUAL.md
  - Used 192.168.10.x for management (now 192.168.200.x)

## 🎯 Quick Reference

### Node Names & IPs (Current)

| Proxmox Node    | Bijnaam        | Management IP     | Primary Role           |
|-----------------|----------------|-------------------|------------------------|
| pve-qotom01     | vuurbuur       | 192.168.200.200   | Edge/OPNsense host     |
| pve-hx310-db    | breintrein     | 192.168.200.201   | Databases & services   |
| pve-hx310-arr   | downloadboef   | 192.168.200.202   | Media automation       |
| pve-5700g       | klusbus        | 192.168.200.203   | Docker workloads       |
| pve-8845hs      | hoofdstuk      | 192.168.200.204   | AI controller          |
| pve-x2686-x2    | denkdoos       | 192.168.200.205   | AI worker (GPU)        |

### Services (Current)

| Service     | IP               | Container | Host       |
|-------------|------------------|-----------|------------|
| PostgreSQL  | 192.168.110.20   | CT 101    | breintrein |
| Vaultwarden | 192.168.100.21   | CT 102    | breintrein |
| Gitea       | 192.168.100.22   | CT 103    | breintrein |
| Wiki.js     | 192.168.100.23   | CT 104    | breintrein |

### What's Next (From Roadmap)

**Immediate (Phase 3 completion):**
- [ ] Set up HTTPS reverse proxy
- [ ] Implement backup automation
- [ ] Deploy remaining planned services

**Near Future (Phase 4):**
- [ ] Implement VLAN segmentation
- [ ] Configure OPNsense firewall rules
- [ ] No IP renumbering needed (already pre-organized)

**Later (Phases 5-7):**
- [ ] AI controller deployment (hoofdstuk)
- [ ] AI worker configuration (denkdoos)
- [ ] Backup & restore strategy

## 📖 How to Use This Documentation

1. **For current network info**: Start with `2025-12-ip-plan-ACTUAL.md`
2. **For planning**: Read `10-roadmap.md` to understand phased approach
3. **For hardware specs**: See `/docs/hw/` directory
4. **For service placement**: See `40-service-inventory-and-placement.md`

## 🔄 When Things Change

When significant infrastructure changes happen:
1. Update `2025-12-ip-plan-ACTUAL.md` (or create new month version)
2. Update this STATUS.md
3. Mark old docs as deprecated if needed
4. Commit with descriptive message

---

**Need help?** Check the roadmap first, then review the actual deployment doc.
