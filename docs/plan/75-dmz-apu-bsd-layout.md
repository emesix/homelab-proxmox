# 75 – DMZ BSD Layout voor APU1 & APU2

Dit document beschrijft het ontwerp voor de **DMZ-laag** op basis van
twee PC Engines APU-systemen, draaiend op een BSD-variant met
jails-/chroot-achtige isolatie.

Doel:

- Mailserver/relay, reverse proxy en VPN **buiten** de kern van het homelab houden.
- De APU’s inzetten als **special-purpose DMZ-apparaten** met minimale attack surface.
- Strakke scheiding tussen:
  - WAN / internet,
  - DMZ,
  - interne frontend/backend/management VLANs.

We gaan uit van:

- Qotom/OPNsense als centrale router/firewall (`vuurbuur`).
- DMZ als eigen VLAN/subnet, bijvoorbeeld `10.10.40.0/24`.
- Backend/Frontend/Management VLANs zoals beschreven in:
  - `50-network-layout-and-security-levels.md`.

APU’s:

- **APU2 (4 GB)** → reverse proxy + VPN endpoint.
- **APU1 (4 GB)** → mail-relayserver.

BSD-voorkeur: je hebt aangegeven een **BSD met jails-achtige services** te willen.
In dit document ontwerpen we de layout op basis van **FreeBSD + jails** als hoofdvariant,
maar je kunt dezelfde rolverdeling in grote lijnen ook met OpenBSD + chroot/httpd/smtpd
realiseren.

---

## 1. Netwerkpositie in de totale architectuur

### 1.1. DMZ VLAN

- VLAN-ID: bijvoorbeeld **40**.
- Subnet: `10.10.40.0/24`.
- Gateway: `10.10.40.1` (OPNsense/`vuurbuur` DMZ-interface).
- DNS: OPNsense of een interne DNS-server (afhankelijk van je DNS-strategie).

De APU’s hangen met één NIC in dit DMZ-subnet:

- **APU2** – reverse proxy + VPN
  - Hostnaam (technisch): `apu2-dmz.local.emesix.nl`
  - IP: `10.10.40.2`
- **APU1** – mail-relay
  - Hostnaam: `apu1-dmz.local.emesix.nl`
  - IP: `10.10.40.3`

OPNsense-firewall (WAN → DMZ):

- Alleen noodzakelijke poorten van internet naar deze twee IP’s:
  - APU2: 80/443 (HTTP/HTTPS), VPN-poort (bijv. UDP 51820 voor WireGuard).
  - APU1: 25/587/465 (SMTP/Submission met TLS).

DMZ → backend:

- APU2 (reverse proxy) mag alleen HTTP/HTTPS naar backend- en frontend-services.
- APU1 (mail) mag alleen SMTP naar interne mailserver-VM’s.
- Geen generieke “any/any” regels.

---

## 2. FreeBSD + jails – hoofdvariant

### 2.1. Waarom FreeBSD hier

- FreeBSD-jails bieden kernel-level isolatie voor services, met:
  - eigen filesystem,
  - beperkte privileges,
  - eigen netwerk (met VNET-jails),
  - goed passende performance op APU1/APU2.
- Je kunt per functie een aparte jail maken:
  - proxy-jail,
  - VPN-jail,
  - mail-jail,
  - zonder dat je op iedere jail een volledig OS hoeft te draaien.

OpenBSD blijft een goede optie voor minimalistische, hard-geharde appliances,
maar omdat je expliciet “jails-achtige” isolatie wilt, is FreeBSD als basis op
de APU’s het meest logisch.

---

## 3. APU2 – Reverse Proxy & VPN (FreeBSD + jails)

**Rol:** alle HTTP/HTTPS-verkeer van buiten (en eventueel van LAN) bundelen,
TLS termineren, doorsturen naar interne services, en een veilige VPN-endpoint
bieden om in te loggen op je netwerk.

### 3.1. Hostconfig APU2

- OS: **FreeBSD** (bijv. 14.x).
- Services op de host zelf:
  - `pf` als firewall (hostniveau).
  - `sshd` voor beheer (alleen op DMZ-IP, restricted).
- Netwerk:
  - NIC `igb0` (voorbeeld) in DMZ VLAN, IP `10.10.40.2/24`.
  - Default gateway: `10.10.40.1` (OPNsense).

Firewall op host (pf):

- Toestaan:
  - Inkomend:
    - WAN/OPNsense → TCP 80, 443 → proxy-jail.
    - WAN/OPNsense → UDP 51820 (bijv.) → VPN-jail.
  - Uitgaand:
    - Naar backend-IPs op HTTP/HTTPS voor reverse proxy backends.
    - Naar interne DNS/ACME-services.
- Blokkeren:
  - Overig inkomend verkeer.
  - DMZ → internet alleen waar nodig (ACME, updates).

### 3.2. Jails op APU2

#### 3.2.1. Jail: `jail_proxy`

- Functie: reverse proxy voor publieke en interne diensten.
- IP: bijv. `10.10.40.12` (DMZ, VNET-jail) óf shared host-IP met aparte poorten.
- Software:
  - Keuze: **Nginx**, **Caddy** of **Traefik**.
  - TLS:
    - ACME (Let’s Encrypt) voor `*.emesix.nl`, `*.brakshoofden.com`.
- Voorbeeld backends:
  - `wiki.emesix.nl` → `wiki-brein.local.emesix.nl` (backend VLAN 100/110).
  - `vault.emesix.nl` → `kluisbaas.local.emesix.nl`.
  - `openwebui.emesix.nl` → `praatpaal.local.emesix.nl`.
  - `media.emesix.nl` → `downloadboef` web-UI.

Firewall rol:

- pf op host:
  - NAT/port-forward: 80/443 naar `jail_proxy`.
- pf in jail (optioneel, met VNET):
  - Extra restricties op uitgaand verkeer.

#### 3.2.2. Jail: `jail_vpn`

- Functie: VPN endpoint voor jou/vertrouwde clients.
- IP: bijv. `10.10.40.13`.
- Software:
  - WireGuard (via FreeBSD-port) of OpenVPN.
- Config:
  - Luisteren op UDP 51820 (of andere poort).
  - Allowed IP’s:
    - routes naar `VLAN 30` (privileged users),
    - `VLAN 200` (management) via policy
    - eventueel andere interne VLANs.
- Firewall:
  - Host pf: WAN → 51820 → `jail_vpn`.
  - Binnenkomende VPN-clients krijgen een intern subnet (bijv. `10.99.0.0/24`),
    dat via OPNsense geforward wordt naar de juiste VLANs met restricties.

---

## 4. APU1 – Mail Relay (FreeBSD + jail)

**Rol:** mail-voorkant voor je domeinen `emesix.nl` en `brakshoofden.com`.

- Inkomende mail van internet:
  - komt binnen op APU1,
  - wordt doorgegeven aan interne mailserver-VM (bijv. in backend VLAN).
- Uitgaande mail:
  - interne systemen sturen mail naar APU1 als **smarthost**,
  - APU1 verstuurt mail naar de buitenwereld, met correcte SPF/DKIM/DMARC-config.

### 4.1. Hostconfig APU1

- OS: **FreeBSD** (zelfde versie als APU2 voor gemak).
- Host-services:
  - `pf` als firewall,
  - `sshd` voor beheer.
- Netwerk:
  - NIC `igb0` (voorbeeld) in DMZ VLAN, IP `10.10.40.3/24`.
  - Gateway: `10.10.40.1` (OPNsense).

pf op host:

- Inkomend:
  - WAN/OPNsense → TCP 25, 587, 465 → `jail_mail`.
- Uitgaand:
  - SMTP naar internet (poort 25) naar ontvangers.
  - SMTP naar interne mailserver-VM (backend).
- Al het andere blokkeren.

### 4.2. Jail: `jail_mail`

- Functie: Postfix-based mail-relay.
- IP: bijv. `10.10.40.23`.
- Software:
  - **Postfix** als MTA.
  - Optioneel `rspamd`/`amavisd`/`spamassassin` voor spamfiltering.
- Routing:
  - Domains `emesix.nl`, `brakshoofden.com`:
    - MX-records → APU1 DMZ-IP → `jail_mail`.
    - Postfix `transport`-maps: afleveren bij interne mailserver-VM.
  - Uitgaand:
    - interne mailserver en andere hosts → APU1 (`relayhost` of smarthost).
    - APU1 stuurt uit naar internet.

- Beveiliging:
  - TLS afdwingen voor Submission (587/465).
  - SPF/DKIM/DMARC correct configureren (in combinatie met DNS-records).
  - Rate limiting en basis anti-abuse maatregelen.

---

## 5. Koppeling met OPNsense en interne VLAN’s

### 5.1. OPNsense → DMZ

OPNsense NAT/port forwarding:

- WAN → APU2:80/443 (HTTP/HTTPS).
- WAN → APU2:UDP 51820 (VPN).
- WAN → APU1:25/587/465 (SMTP/Submission).

Firewall-regels:

- Alleen bovengenoemde poorten toestaan.
- Logging van mislukte verbindingspogingen (voor detectie van scans/brute-force).

### 5.2. DMZ → Backend

- APU2:
  - mag HTTP/HTTPS naar geselecteerde backend-IPs (Wiki.js, Vaultwarden, Open WebUI, media).
  - mag geen directe random communicatie met DB’s; de applicaties praten met DB’s.
- APU1:
  - mag SMTP naar de interne mailserver-VM (backend).
  - mag SMTP naar internet (outbound mail).

### 5.3. Monitoring & logging

- DMZ-hosts loggen naar:
  - centrale syslog/loghost in `VLAN 210` (Monitoring & Logging),
  - of naar een backend-loggingstack (Loki/Graylog).
- OPNsense logt DMZ-verkeer, zodat je unusual patterns (port scans, brute force) kunt detecteren.

---

## 6. Alternatief: OpenBSD-variant (optioneel)

Mocht je besluiten dat je voor de APU’s liever **OpenBSD** gebruikt (maximale minimalisme/hardening),
dan is de mapping grofweg:

- **APU2 (OpenBSD)**:
  - `httpd` + `relayd` als reverse proxy,
  - `iked` of WireGuard-port voor VPN,
  - `pf` + `unveil`/`pledge` hardening.
- **APU1 (OpenBSD)**:
  - `smtpd` als MTA, eventueel met extra filtering,
  - zelfde DMZ-positionering.

Je verliest dan wel de “jails”-feature, maar wint een zeer minimalistische en sterk geharde base-OS-config.
Voor jouw voorkeur (“BSD + jails-achtig”) is FreeBSD waarschijnlijk logischer; OpenBSD kun je later
altijd nog testen als alternatief voor één van de twee APU’s.

---

## 7. Samenvatting

- **APU2** wordt de **DMZ-poortwachter**:
  - FreeBSD host,
  - pf firewall,
  - jails voor:
    - `jail_proxy` (reverse proxy),
    - `jail_vpn` (WireGuard/OpenVPN).
- **APU1** wordt de **mail-hond**:
  - FreeBSD host,
  - pf firewall,
  - `jail_mail` (Postfix mail-relay + optioneel spamfiltering).

Beide APU’s:

- Hangen in het DMZ-VLAN (`10.10.40.0/24`).
- Krijgen strakke firewall-regels op OPNsense én op de host (pf).
- Praten alleen met:
  - internet op de juiste poorten,
  - backend-services op strikt gedefinieerde poorten,
  - centrale logging/monitoring.

Dit ontwerp maakt de DMZ onafhankelijk van je kern-Proxmox/AI-cluster en geeft je de vrijheid om:
- intern mailservers en backends te wisselen,
- nieuwe diensten toe te voegen achter de reverse proxy,
zonder DNS/MX-records of publieke endpoints steeds volledig om te gooien.
