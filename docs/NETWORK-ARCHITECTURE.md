# Network Architecture - Backend/Frontend Separation

This document describes the dual-network architecture for homelab services and how to configure containers with proper network isolation.

## Network Segmentation Model

### Frontend Networks (User-Accessible)
- **VLAN 30** - User LAN (`10.10.30.0/24`)
  - Personal devices
  - Workstations
  - Access to frontend services only

- **VLAN 40** - DMZ (`10.10.40.0/24`)
  - Reverse proxy (Nginx/Traefik)
  - Public-facing services
  - Isolated from backend

### Backend Networks (Service-to-Service)
- **VLAN 100** - Backend Services (`10.10.100.0/24`)
  - General application services
  - Docker networks
  - Internal APIs

- **VLAN 110** - Database Backend (`10.10.110.0/24`)
  - PostgreSQL, Redis, etc.
  - **CRITICAL:** Never exposed to frontend
  - Only accessible from backend VLANs

- **VLAN 120** - AI Backend (`10.10.120.0/24`)
  - AI controller (hoofdstuk)
  - AI worker (denkdoos)
  - Model serving endpoints

- **VLAN 130** - Storage Backend (`10.10.130.0/24`)
  - NAS access
  - Backup connections
  - ZFS replication

### Management Network
- **VLAN 200** - Management (`10.10.200.0/24`)
  - Proxmox host interfaces
  - SSH access to containers
  - Monitoring agents
  - Admin tools (pgAdmin, Portainer, etc.)

## Service Network Assignment

### PostgreSQL (pg-brein)
- **Primary:** VLAN 110 (`10.10.110.20`) - Database backend
  - Services connect here
  - Port 5432 available only to backend VLANs
- **Secondary:** VLAN 200 (`10.10.200.100`) - Management
  - SSH access
  - pgAdmin connections
  - Monitoring

### Vaultwarden (kluisbaas)
- **Primary:** VLAN 100 (`10.10.100.21`) - Backend services
  - API access for integrations
  - Connects to PostgreSQL on VLAN 110
- **Secondary:** VLAN 40 (`10.10.40.21`) - DMZ
  - Reverse proxy forwards requests here
  - Port 8000 (HTTPS) exposed via proxy only
- **Tertiary:** VLAN 200 (`10.10.200.101`) - Management
  - SSH access
  - Admin panel

### Gitea (codekroeg)
- **Primary:** VLAN 100 (`10.10.100.22`) - Backend services
  - Git operations via SSH (port 22)
  - Connects to PostgreSQL on VLAN 110
- **Secondary:** VLAN 40 (`10.10.40.22`) - DMZ
  - Web UI via reverse proxy
  - Port 3000 forwarded
- **Tertiary:** VLAN 200 (`10.10.200.102`) - Management

### Wiki.js (wiki-brein)
- **Primary:** VLAN 100 (`10.10.100.23`) - Backend services
  - Connects to PostgreSQL on VLAN 110
  - Syncs with Gitea on VLAN 100
- **Secondary:** VLAN 40 (`10.10.40.23`) - DMZ
  - Web UI via reverse proxy
- **Tertiary:** VLAN 200 (`10.10.200.103`) - Management

### Docker Networks
Docker containers should use **macvlan** or **bridge** networks mapped to backend VLANs:

```yaml
networks:
  backend_services:
    driver: macvlan
    driver_opts:
      parent: eth0.100  # VLAN 100 tagged interface
    ipam:
      config:
        - subnet: 10.10.100.0/24
          gateway: 10.10.100.1
          
  database_backend:
    driver: macvlan
    driver_opts:
      parent: eth0.110  # VLAN 110 tagged interface
    ipam:
      config:
        - subnet: 10.10.110.0/24
          gateway: 10.10.110.1
```

## Firewall Rules (OPNsense)

### Backend → Database (VLAN 100 → VLAN 110)
```
Action: Allow
Source: VLAN 100 net
Destination: 10.10.110.20 (PostgreSQL)
Port: 5432
Protocol: TCP
```

### Management → Backend (VLAN 200 → VLAN 110)
```
Action: Allow
Source: VLAN 200 net
Destination: VLAN 110 net
Port: 5432, 6379 (database ports)
Protocol: TCP
```

### Frontend → Backend (DENY)
```
Action: Reject
Source: VLAN 30 net, VLAN 40 net
Destination: VLAN 110 net
Description: Block direct frontend to database access
```

### DMZ → Backend Services (VLAN 40 → VLAN 100)
```
Action: Allow
Source: 10.10.40.1 (reverse proxy)
Destination: Specific backend IPs
Port: Application ports (3000, 8000, etc.)
Protocol: TCP
```

## Implementation Phases

### Phase 1: Staging (Current)
- **Network:** Flat `192.168.10.0/16`
- **Containers:** Single interface
- **Goal:** Get services running
- **Duration:** Until cluster stable

### Phase 2: VLAN Transition
- **Network:** VLANs configured on OPNsense and switches
- **Change netmask:** `/16` → `/24` per VLAN
- **IP Changes:** None (already in correct /24 blocks)
- **Add VLAN tags:** Via Proxmox web UI

### Phase 3: Dual Network Implementation
- **Add secondary interfaces** to containers
- **Configure routing:** Default via primary (backend)
- **Test connectivity:** Between VLANs
- **Implement firewall rules:** Gradually restrict

### Phase 4: Docker Network Integration
- **Create macvlan networks** on backend VLANs
- **Migrate Docker services** to VLAN-aware networks
- **Remove port bindings** on host (use reverse proxy)

## Container Network Configuration

### Single Network (Community Script Default)
```bash
# Via configuration file
export var_net="ip=10.10.110.20/24,gw=10.10.110.1"
```

### Adding Secondary Network (Post-Deployment)

**Method 1: Proxmox Web UI**
1. Select Container → Hardware → Add → Network Device
2. Bridge: `vmbr0`
3. VLAN Tag: `200` (for management)
4. Rate limit: (optional)
5. Firewall: Enable

**Method 2: CLI**
```bash
# Add management interface (VLAN 200)
pct set 100 -net1 name=eth1,bridge=vmbr0,tag=200,firewall=1

# Add DMZ interface (VLAN 40) for web-accessible services
pct set 101 -net1 name=eth1,bridge=vmbr0,tag=40,firewall=1
```

**Method 3: Container Configuration File**
Edit `/etc/pve/lxc/<ctid>.conf`:
```
# Primary network (backend)
net0: name=eth0,bridge=vmbr0,tag=110,firewall=1,hwaddr=XX:XX:XX:XX:XX:XX,ip=dhcp,type=veth

# Secondary network (management)
net1: name=eth1,bridge=vmbr0,tag=200,firewall=1,hwaddr=XX:XX:XX:XX:XX:XX,ip=dhcp,type=veth
```

### Inside Container Network Config

**/etc/network/interfaces** (Debian/Ubuntu):
```bash
# Primary interface (backend)
auto eth0
iface eth0 inet static
    address 10.10.110.20/24
    gateway 10.10.110.1
    dns-nameservers 10.10.200.1

# Secondary interface (management)
auto eth1
iface eth1 inet static
    address 10.10.200.100/24
    # No gateway (default already set on eth0)
```

### Routing Policy
```bash
# Add policy routing for management interface
# /etc/iproute2/rt_tables
200 mgmt

# Add routes
ip route add 10.10.200.0/24 dev eth1 src 10.10.200.100 table mgmt
ip route add default via 10.10.200.1 dev eth1 table mgmt
ip rule add from 10.10.200.100/32 table mgmt
ip rule add to 10.10.200.0/24 table mgmt
```

## Docker Compose with VLANs

### Example: Application Stack on Backend VLAN
```yaml
version: '3.8'

services:
  app:
    image: myapp:latest
    networks:
      backend:
        ipv4_address: 10.10.100.50
    environment:
      DB_HOST: 10.10.110.20  # PostgreSQL on VLAN 110
      DB_PORT: 5432

networks:
  backend:
    driver: macvlan
    driver_opts:
      parent: eth0.100  # VLAN 100 interface
    ipam:
      config:
        - subnet: 10.10.100.0/24
          gateway: 10.10.100.1
          ip_range: 10.10.100.50/28  # Reserve .50-.63 for containers
```

### Example: Service with Both Backend and DMZ Access
```yaml
version: '3.8'

services:
  webapp:
    image: webapp:latest
    networks:
      backend:
        ipv4_address: 10.10.100.60
      dmz:
        ipv4_address: 10.10.40.60

networks:
  backend:
    driver: macvlan
    driver_opts:
      parent: eth0.100
    ipam:
      config:
        - subnet: 10.10.100.0/24
          gateway: 10.10.100.1
          
  dmz:
    driver: macvlan
    driver_opts:
      parent: eth0.40
    ipam:
      config:
        - subnet: 10.10.40.0/24
          gateway: 10.10.40.1
```

## Testing Network Isolation

### From Frontend (Should FAIL)
```bash
# From workstation on VLAN 30
ping 10.10.110.20        # Should timeout (no route)
telnet 10.10.110.20 5432 # Should be blocked by firewall
```

### From Backend (Should SUCCEED)
```bash
# From service on VLAN 100
ping 10.10.110.20        # Should work
psql -h 10.10.110.20 -U gitea -d gitea  # Should connect
```

### From Management (Should SUCCEED)
```bash
# From admin workstation on VLAN 200
ssh root@10.10.200.100   # Should connect to container
psql -h 10.10.110.20 -U postgres  # Should connect to DB
```

## Security Considerations

1. **Never expose database directly to frontend VLANs**
   - Always use application tier as intermediary
   - Database should only be accessible from backend VLANs

2. **Use reverse proxy for all web UIs**
   - Frontend users hit reverse proxy on DMZ
   - Reverse proxy forwards to backend services
   - Backend services never directly accessible from frontend

3. **Management network isolation**
   - SSH only from management VLAN
   - Separate from user networks
   - Monitor for anomalous traffic

4. **Docker network isolation**
   - Use macvlan/ipvlan, not bridge mode
   - Prevents containers from accessing host network
   - Proper VLAN tagging enforced

5. **Least privilege**
   - Services only get network access they need
   - Use firewall rules to enforce
   - Log denied connections

## Troubleshooting

### Container can't reach PostgreSQL
```bash
# Check routing
ip route show

# Check if VLAN tag is set
cat /etc/pve/lxc/100.conf | grep net

# Test from container
ping 10.10.110.1  # Gateway
ping 10.10.110.20  # PostgreSQL
telnet 10.10.110.20 5432  # PostgreSQL port
```

### Docker container can't join macvlan network
```bash
# Verify parent interface exists
ip link show eth0.100

# Create VLAN interface if missing
ip link add link eth0 name eth0.100 type vlan id 100
ip link set eth0.100 up

# Check OPNsense allows traffic
# Firewall → Log Files → Live View
```

### Service accessible from wrong VLAN
```bash
# Check OPNsense firewall rules
# Firewall → Rules → VLAN 30

# Check container firewall
iptables -L -n -v

# Verify VLAN tagging
tcpdump -i vmbr0 -e | grep vlan
```

## Related Documentation

- `docs/plan/50-network-layout-and-security-levels.md` - Full network design
- `docs/plan/55-staging-network-and-vlan-transition.md` - Transition strategy
- `docs/decisions/ADR-001-network-segmentation-and-vlans.md` - Architecture decisions
- `automation/configs/*-dual-network.conf` - Dual-network configuration files

## Next Steps

1. **Review this architecture** with documented network plan
2. **Test dual-network setup** on single container first
3. **Create automation** for adding secondary interfaces
4. **Update deployment scripts** to handle multi-network configs
5. **Document firewall rules** in OPNsense configuration
