# Homelab Network Plan – ACTUAL DEPLOYMENT (December 2025)

> **Status:** This reflects the ACTUAL deployed configuration as of Dec 1, 2025  
> **Supersedes:** Previous 192.168.10.x plans - those IPs have been migrated  
> **Aligns with:** `/docs/plan/10-roadmap.md` and `/docs/plan/50-network-layout-and-security-levels.md`

## 1. Current Network State

- **Network:** `192.168.0.0/16` (flat, no VLANs yet)
- **Gateway:** `192.168.1.1` (OPNsense LAN)
- **DNS:** OPNsense Unbound on `192.168.1.1`
- **Future:** VLANs will be added in Phase 4, but IPs are already organized for that

## 2. IP Address Scheme

### 2.1 Proxmox Management (192.168.200.x)

All Proxmox hypervisor management interfaces:

| Hostname        | Bijnaam (nickname) | Management IP     | Hardware                              |
|-----------------|--------------------|-------------------|---------------------------------------|
| `pve-qotom01`   | **vuurbuur**       | `192.168.200.200` | Qotom 1U, Intel Atom C3758R          |
| `pve-hx310-db`  | **breintrein**     | `192.168.200.201` | OnLogic HX310, Elkhart Lake          |
| `pve-hx310-arr` | **downloadboef**   | `192.168.200.202` | OnLogic HX310, Elkhart Lake          |
| `pve-5700g`     | **klusbus**        | `192.168.200.203` | AMD Ryzen 7 5700G                     |
| `pve-8845hs`    | **hoofdstuk**      | `192.168.200.204` | AMD Ryzen 7 8845HS (AI controller)   |
| `pve-x2686-x2`  | **denkdoos**       | `192.168.200.205` | Dual Xeon E5-2686v4 (AI worker)      |

**Note:** Original plan used 192.168.200.11-16, but we're using 200-205 for consistency.

### 2.2 Backend Services (192.168.100.x)

Generic backend applications:

| Service      | Container | IP               | Host          | Notes                    |
|--------------|-----------|------------------|---------------|--------------------------|
| Vaultwarden  | CT 102    | `192.168.100.21` | breintrein    | Password manager         |
| Gitea        | CT 103    | `192.168.100.22` | breintrein    | Local git hosting        |
| Wiki.js      | CT 104    | `192.168.100.23` | breintrein    | Documentation/knowledge  |

### 2.3 Database Backend (192.168.110.x)

Database and data services:

| Service    | Container | IP               | Host        | Notes                        |
|------------|-----------|------------------|-------------|------------------------------|
| PostgreSQL | CT 101    | `192.168.110.20` | breintrein  | Central DB for all services  |

### 2.4 AI Backend (192.168.120.x) - PLANNED

Reserved for AI services:

- `192.168.120.10-50` - AI controller services (hoofdstuk)
- `192.168.120.51-100` - AI worker services (denkdoos)

### 2.5 Storage Backend (192.168.130.x) - PLANNED

Reserved for NAS and storage services:

- `192.168.130.11` - NAS data plane (schuifkast/unRAID)

## 3. ZFS Storage Configuration

### On Proxmox Nodes

| Node          | Pool               | Type         | Size    | Purpose                    |
|---------------|--------------------|--------------|---------|----------------------------|
| vuurbuur      | rpool              | Mirror       | 460G    | System/VMs                 |
| breintrein    | rpool              | Single       | 928G    | System/containers          |
| breintrein    | datastore          | Single       | 952G    | Data storage               |
| downloadboef  | rpool              | Single       | 928G    | System                     |
| klusbus       | datastore-5700g    | RAID0 stripe | 1.86T   | Docker/workloads (speed)   |
| hoofdstuk     | rpool              | Mirror       | 920G    | System                     |
| denkdoos      | datastore-x2686    | RAID0 stripe | 1.86T   | AI data (extreme speed)    |

**Speed-optimized pools:**
- `datastore-5700g`: 2-disk stripe for Docker I/O
- `datastore-x2686`: 4-disk stripe for AI model loading/inference

## 4. Service Dependencies

```
PostgreSQL (192.168.110.20)
    ↓
    ├─→ Vaultwarden (192.168.100.21)
    ├─→ Gitea (192.168.100.22)
    └─→ Wiki.js (192.168.100.23)
```

## 5. Access & Security

**Current State (Staging):**
- All services on flat 192.168.0.0/16 network
- Web access requires SSH tunnels for HTTPS (WebCrypto requirement)
- Example: `ssh -L 8888:192.168.100.21:80 root@192.168.200.201`

**Future (Phase 4 - VLANs):**
- VLAN 100 = Backend services
- VLAN 110 = Database backend  
- VLAN 200 = Management
- Firewall rules will restrict cross-VLAN access
- Reverse proxy with HTTPS for user access

## 6. Comparison with Old Plan

| Item                    | OLD (Nov)       | NEW (Dec 1)      | Status     |
|-------------------------|-----------------|------------------|------------|
| Proxmox management IPs  | 192.168.10.x    | 192.168.200.x    | ✅ Migrated |
| Service subnet          | Mixed           | 192.168.100.x    | ✅ Migrated |
| Database subnet         | Mixed           | 192.168.110.x    | ✅ Migrated |
| Node nicknames          | Not defined     | Dutch names      | ✅ Added    |
| ZFS performance config  | Not optimized   | Striped for speed| ✅ Done     |

## 7. Next Steps (Per Roadmap)

- [ ] Fix cluster quorum after IP migration
- [ ] Set up HTTPS reverse proxy
- [ ] Add remaining services (per Phase 3)
- [ ] Implement VLANs (Phase 4)
- [ ] Deploy AI controller on hoofdstuk (Phase 5)
- [ ] Deploy AI worker on denkdoos (Phase 6)
