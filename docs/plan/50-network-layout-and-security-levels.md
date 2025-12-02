# 50 – Network Layout & Security Levels

Dit document beschrijft de netwerkindeling op basis van **VLANs** en een
duidelijk **veiligheidsniveau-model**. Het doel is:

- Duidelijke scheiding tussen:
  - onbekende/guest clients,
  - bekende maar niet-geauthenticeerde clients,
  - geauthenticeerde/privileged users,
  - backend-services,
  - management & infra.
- Eén centraal beheerd **backend VLAN-bereik (100–199)** voor services
  (Docker, LXC, VM-backends) zonder overal losse Docker-subnets.
- OPNsense als centrale plek voor:
  - DHCP,
  - firewalling,
  - routing,
  - monitoring van verkeer tussen VLANs.

Interne domein: `*.local.emesix.nl`  
Publieke domeinen: `*.emesix.nl`, `*.brakshoofden.com`

---

## 1. Security Levels

We hanteren vijf veiligheidsniveaus:

1. **Level 0 – Wild West / onbekend**
   - Onbekende MAC-adressen, gasten, BYOD, IoT-tests.
   - Minimale toegang, alleen streng beperkt internet.

2. **Level 1 – Low Trust / bekende MAC, geen identity**
   - Devices die jij fysiek bezit of kent, maar zonder user-auth.
   - Bijvoorbeeld TV’s, tablets, semi-vertrouwde apparaten.

3. **Level 2 – Medium Trust / bekende MAC + user-auth**
   - Jouw eigen laptops/telefoons met correcte WiFi-sleutel en evt. 802.1X/Domeinlogin.
   - Toegang tot frontend-services en reverse proxy.

4. **Level 3 – High Trust / Backend Services**
   - Servers, VM’s, LXC’s, Docker-containers die applicatielogica en data
     draaien, maar geen UI direct aan het internet.

5. **Level 4 – Very High Trust / Infra & Management**
   - Proxmox management, OPNsense management, IPMI, NAS management, logging/monitoring.

---

## 2. VLAN-indeling per veiligheidsniveau

### 2.1. 0–99: Guest & User Access

**VLAN 10 – Guest / Unknown MAC (Level 0)**  
- Subnet: `192.168.10.0/24`
- Type: Onbekende gasten, BYOD, IoT-tests.  
- Toegang:
  - Alleen naar internet (HTTP/HTTPS/DNS).
  - Geen toegang tot backend, frontend of management.
- Gebruiken voor:
  - “Open” gast-WiFi (met captive portal of sterke beperkingen).
  - Tijdelijke devices.

---

**VLAN 20 – Guest / Known MAC (Level 1)**  
- Subnet: `192.168.20.0/24`
- Type: Apparaten met bekende MAC, maar geen user-auth:
  - TV’s, tablets, consoles, semi-vertrouwde apparaten.
- Toegang:
  - Internettoegang (iets minder streng dan VLAN 10).
  - Geen directe toegang tot backend.
  - Beperkte toegang tot specifieke frontend-services via reverse proxy (bijv. media UI).
- Beveiliging:
  - Statische DHCP-leases per MAC.
  - Firewallregels per apparaatgroep.

---

**VLAN 30 – Privileged Users (Level 2)**  
- Subnet: `192.168.30.0/24`
- Type:
  - Jouw eigen werkstations/laptops/telefoons.
  - Devices met bekende MAC **en** juiste credentials (WiFi-key / 802.1X / domain).
- Toegang:
  - Volledige toegang tot frontend-laag (reverse proxy, interne web-UI’s).
  - Geen directe verbindingen naar backend-DB’s of interne API’s; dat gaat via
    frontend/API-gateways of expliciete firewallrules.
- Beveiliging:
  - Sterke WiFi-security (WPA2/3 + eventueel RADIUS/802.1X).
  - Logging van uitgaand verkeer.

---

### 2.2. 100–199: Backend Services (Level 3)

Dit bereik is gereserveerd voor **backend-services** (Docker, LXC, VM’s) zodat
er één consistent adresplan is en je niet per server allerlei losse Docker-subnets
hoeft te beheren.

**VLAN 100 – Generic Backend Services**  
- Subnet: `192.168.100.0/24`
- Type:
  - Standaard backend-applicaties:
    - Wiki backend,
    - Gitea/Forgejo,
    - Vaultwarden backend,
    - *ARR backend als dat niet op een eigen VLAN hoeft.
- Toegang:
  - Geen inkomende verbindingen vanaf internet.
  - Alleen benaderbaar vanuit:
    - frontend-reverse proxy’s,
    - specifieke user-subnets via firewall (indien nodig).
  - Uitgaand:
    - Updates (apt, docker, etc.),
    - Beperkte API calls naar bekende internet-endpoints.

---

**VLAN 110 – Data & DB Backend**  
- Subnet: `192.168.110.0/24`
- Type:
  - Databases en datastores:
    - PostgreSQL,
    - evt. Redis, MQ, etc.
- Toegang:
  - Alleen vanaf:
    - applicaties in VLAN 100 en 120 (met expliciete firewall-regels),
    - monitoring/backup-systemen.
  - Geen user-subnetten direct naar DB-poorten.

---

**VLAN 120 – AI Backend**  
- Subnet: `192.168.120.0/24`
- Type:
  - AI-controller (`hoofdstuk`, `pve-8845hs`)
  - AI-worker (`denkdoos`, `pmx-ai-worker`)
- Toegang:
  - Frontend/DMZ/Proxy mag alleen naar expliciete API-poorten op deze hosts.
  - Uitgaand verkeer naar internet beperkt tot:
    - AI-API’s (OpenRouter, OpenAI),
    - package repositories.

---

**VLAN 130 – Storage Backend**  
- Subnet: `192.168.130.0/24`
- Type:
  - NAS dataplane (`schuifkast`, `nas-unraid`),
  - NFS/SMB/Rsync verkeer.
- Toegang:
  - Alleen backend-servers/VM’s (VLAN 100/110/120) mogen hierop mounten.
  - Geen directe user-mounts vanaf VLAN 10/20/30.

---

### 2.3. 200+: Management & Infra (Level 4)

**VLAN 200 – Management**  
- Subnet: `192.168.200.0/24`
- Type:
  - Proxmox management voor alle nodes,
  - OPNsense management (WAN/DMZ intern),
  - Switch/AP management,
  - IPMI/Out-of-Band consoles.
- Toegang:
  - Alleen via:
    - VPN vanaf privileged user VLAN (30),
    - of een dedicated jump-host.
  - Geen direct internet op management interfaces.

---

**VLAN 210 – Monitoring & Logging**  
- Subnet: `192.168.210.0/24`
- Type:
  - Netdata, Prometheus, Loki/Graylog, Notifiarr-achtige notificatiediensten.
- Toegang:
  - Mogen data ophalen uit backend-VLANs (100/110/120/130).
  - Uitgaand internet alleen voor meldingen (Discord, mail, Telegram, etc.).

---

## 3. “Wie mag met wie praten?” – matrix

Hoog niveau matrix (standaard-beleid, specifics gaan in OPNsense rules):

| From \ To      | VLAN 10 (guest unk) | VLAN 20 (guest known) | VLAN 30 (priv users) | VLAN 100–130 (backend) | VLAN 200+ (mgmt/mon) | Internet       |
|-----------------|---------------------|------------------------|----------------------|------------------------|----------------------|----------------|
| VLAN 10         | –                   | blok                   | blok                 | blok                   | blok                 | beperkt (web)  |
| VLAN 20         | blok                | –                      | beperkt (bijv. streaming) | sterk beperkt     | blok                 | normaal (maar gefilterd) |
| VLAN 30         | blok                | beperkt                | –                    | beperkt (via proxy/API) | via VPN/jump-host   | normaal        |
| Backend 100–130 | blok                | blok                   | geen direct          | –                      | beperkt (monitoring) | beperkt (updates/APIs) |
| VLAN 200+       | blok                | blok                   | beperkt (management portalen) | beheer (SSH/API) | –                    | zeer beperkt   |

Richtlijn:

- **User → Backend**:  
  In principe altijd via frontend of API-gateways / reverse proxy.
- **Internet → Backend**:  
  Nooit direct, alleen via DMZ/reverse proxy.
- **Backend → Internet**:  
  Alleen wat nodig is (updates, API’s, notificaties).
- **User → Management**:  
  Alleen via VPN / jump-host en alleen voor admin-accounts.

---

## 4. Mapping naar hosts en bijnamen

Korte mapping hoe je de hosts in deze VLAN-structuur hangt:

- **vuurbuur** (`pmx-qotom` / OPNsense VM)
  - Interfaces:
    - VLAN 10, 20, 30 (user-kant),
    - VLAN 100, 110, 120, 130 (backend),
    - VLAN 200, 210 (management/monitoring),
    - plus WAN/DMZ.
- **breintrein** (`pmx-hx310-db`)
  - Primair in VLAN 110 (DB backend) en evt. VLAN 100 voor app-VM/LXC.
- **downloadboef** (`pmx-hx310-arr`)
  - Primair in VLAN 100 (generic backend) en storage-toegang naar VLAN 130.
- **klusbus** (`pmx-docker`)
  - Docker-hosten in VLAN 100 (backend).
- **hoofdstuk** (`pve-8845hs`)
  - In VLAN 120 (AI backend) met API-exposure naar frontend/DMZ.
- **denkdoos** (`pmx-ai-worker`)
  - In VLAN 120 (AI backend), alleen bereikbaar via `hoofdstuk` en management-VLAN.
- **schuifkast** (`nas-unraid`)
  - In VLAN 130 (storage backend) en management-interface in VLAN 200.

---

## 5. Proxmox & OPNsense implementatie (kort)

- **Proxmox:**
  - NIC naar core-switch als trunk, VLAN-aware.
  - Bridges:
    - `vmbr0` (trunk) met VLAN-aware = aan.
  - Per VM/LXC:
    - NIC op `vmbr0` met de juiste VLAN-tag (10/20/30/100/…).

- **OPNsense (op vuurbuur):**
  - Per VLAN een interface aanmaken:
    - `OPT_GUEST10`, `OPT_GUEST20`, `OPT_USER30`,
      `OPT_BACKEND100`, `OPT_DB110`, `OPT_AI120`, `OPT_STOR130`,
      `OPT_MGMT200`, `OPT_MON210`.
  - DHCP per interface aanzetten waar nodig.
  - Firewall-rules inrichten volgens het matrix-model hierboven.

---

Dit document vormt de basis voor:

- je OPNsense-firewallpolicy,
- je Proxmox-bridge/VLAN-config,
- en je Wiki.js-documentatie (waar per host duidelijk is in welke VLANs hij leeft en welk securitylevel dat is).
