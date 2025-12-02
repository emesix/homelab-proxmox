# 20 – Proxmox Cluster & Users

Dit document beschrijft het basisontwerp voor:

- de Proxmox-cluster (welke nodes, welke rollen),
- de gebruikers en rechten in Proxmox,
- hoe we hosts toevoegen aan de cluster,
- hoe we API-tokens veilig willen inzetten.

Het doel is dat:

- je **Qotom**-node de eerste “seed” van de cluster wordt;
- alle andere nodes op een voorspelbare manier worden toegevoegd;
- je niet afhankelijk blijft van `root@pam` voor dagelijks beheer.

---

## 1. Cluster-overzicht

### 1.1. Nodes (bare-metal Proxmox hosts)

| Host hardware        | PVE-hostnaam          | Bijnaam        | Rol                                |
|----------------------|-----------------------|----------------|-------------------------------------|
| Qotom 1U             | `pmx-qotom`           | **vuurbuur**   | Eerste node, OPNsense-VM, infra    |
| HX310-1 (DB)         | `pmx-hx310-db`        | **breintrein** | DB/infra-services (Postgres/Wiki)  |
| HX310-2 (*ARR)       | `pmx-hx310-arr`       | **downloadboef** | *ARR en media-backend           |
| B450 5700G           | `pmx-docker`          | **klusbus**    | Docker workloads                    |
| AMD 8845HS     | `pve-8845hs`          | **hoofdstuk**  | AI-controller & orkestrator         |
| X99 dual Xeon        | `pmx-ai-worker`       | **denkdoos**   | AI-worker / GPU compute             |

Unraid NAS en de APU’s zijn **geen** Proxmox-nodes; die blijven apart beheer.

---

## 2. Cluster-aanpak

### 2.1. Qotom als eerste node

1. Installeer Proxmox op Qotom (`pmx-qotom`).
2. Gebruik een IP uit je management- of user-VLAN (tijdelijk mag het simpel).
3. Run het PVE Post-install script (community-scripts) om:
   - enterprise repo uit te zetten,
   - no-subscription repo te activeren,
   - basis updates te doen.

Zodra `pmx-qotom` stabiel draait:

- wordt dit de node waar de OPNsense-VM gaat draaien;
- en de node waarmee je de cluster initieel gaat beheren.

### 2.2. Cluster init op Qotom

Op `pmx-qotom`:

- Controleer dat de hostname goed staat (`pmx-qotom`),
- Controleer tijd/NTP.

Cluster aanmaken:

```bash
pvecm create homelab-cluster
```

- Clusternaam: `homelab-cluster`.

---

## 3. Nodes toevoegen aan de cluster

### 3.1. Voorwaarden per nieuwe node

Voor elke nieuwe node (HX310’s, B450, X99):

1. Proxmox installeren met juiste hostname.
2. Repos via PVE Post-install script fixen.
3. SSH-toegang van Qotom naar de nieuwe node (tijdelijk root-key of wachtwoord).

### 3.2. Node join

Op **doelnode** (bijv. `pmx-hx310-db`):

- Zorg dat je de IP van `pmx-qotom` kunt pingen.

Op **Qotom**:

```bash
pvecm status   # controleren dat cluster ok is
```

Op **doelnode**:

```bash
pvecm add <IP-van-pmx-qotom>
```

Volg de prompt voor root-wachtwoord of key-based auth.

Na succesvolle join:

- De nieuwe node verschijnt in de Proxmox-UI aan de linkerkant.
- Je kunt resources (VM/LXC) op die node aanmaken of migreren.

Herhaal dit voor:

- `pmx-hx310-db`,
- `pmx-hx310-arr`,
- `pmx-docker`,
- `pve-8845hs`,
- `pmx-ai-worker`.

---

## 4. Gebruikers & rollen in Proxmox

### 4.1. Root vs admin-gebruiker

`root@pam` blijft bestaan, maar:

- wordt alleen gebruikt voor:
  - cluster-init,
  - noodoperaties,
  - recovery.
- niet voor dagelijks beheer en API-tokens.

Daarom maken we een admin-gebruiker:

- User: `vincent@pve`
- Realm: `pve`
- Rol: `Administrator` op `/` (cluster breed).

Stappen:

1. In PVE-UI: **Datacenter → Permissions → Users → Add**.
2. User ID: `vincent`
3. Realm: `pve`
4. E-mailadres: jouw eigen mailadres
5. Wachtwoord: **random, in Vaultwarden opslaan**.

Daarna:

- **Permissions → Add → User Permission**:
  - Path: `/`
  - User: `vincent@pve`
  - Role: `Administrator`

### 4.2. Extra (optionele) rollen

Je kunt later aanvullende rollen overwegen:

- `BackupAdmin` – mag alleen backups en restores.
- `VMAdmin` – mag VM’s beheren maar niet de cluster zelf.
- `ReadOnly` – voor een read-only UI-account.

Voor nu: focus op `vincent@pve` als primary admin.

---

## 5. API-tokens

### 5.1. Gebruiksscenario’s

Je wilt API-tokens kunnen inzetten voor:

- Automation (bijv. Warp.dev, scripts),
- Integraties (backups, monitoring).

Regel:

- Geen tokens op `root@pam`.
- Tokens bij voorkeur op `vincent@pve` of een dedicated “service user”.

### 5.2. Token aanmaken

In de PVE-UI:

1. Ga naar: **Datacenter → Permissions → API Tokens**.
2. Kies `Add`.
3. User: `vincent@pve` of aparte user zoals `automation@pve`.
4. Token ID: bijv. `warpdev`.
5. Toggle:
   - `Privilege Separation`: **aan** als je per-token rechten wilt toekennen.
   - Expiry: stel een datum in als extra veiligheid.

Kopieer de token **eenmalig** en sla hem op in Vaultwarden onder:

- `Proxmox API Token – warpdev – pmx-qotom`.

### 5.3. Rechten voor tokens

Als `Privilege Separation` aan staat:

- Maak een ACL aan voor het token specifiek:
  - Path: `/`
  - Token: `vincent@pve!warpdev`
  - Role: bijvoorbeeld `PVEAdmin` of een custom rol met beperkter bereik.

Automations (zoals Warp.dev) krijgen dan:

- dezelfde of beperkte rechten vergeleken met je admin-gebruiker, maar:
- je kunt het token intrekken zonder het account zelf te breken.

---

## 6. Checklists

### 6.1. Cluster-basics klaar?

- [ ] `pmx-qotom` draait Proxmox met fixed IP.
- [ ] `homelab-cluster` is aangemaakt.
- [ ] `vincent@pve` bestaat en heeft Administrator-rechten op `/`.
- [ ] Je kunt inloggen als `vincent@pve` in de UI.
- [ ] Je hebt minstens één API-token aangemaakt en in Vaultwarden gezet.

### 6.2. Node-join checklist

Voor elke extra node:

- [ ] Proxmox geïnstalleerd met correcte hostname.
- [ ] PVE Post-install script gedraaid (repos/updates ok).
- [ ] Node kan `pmx-qotom` pingen.
- [ ] `pvecm add <ip-qotom>` is succesvol geweest.
- [ ] Node verschijnt in de cluster-UI.
