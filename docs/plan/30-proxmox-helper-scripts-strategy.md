# 30 – Proxmox Helper Scripts & Community Tools Strategie

Dit document beschrijft hoe en wanneer we de
[`community-scripts/ProxmoxVE`](https://github.com/community-scripts/ProxmoxVE)
en andere helper-tools willen inzetten tijdens:

- installatie van nieuwe nodes,
- post-install hardening,
- dagelijkse beheer- en migratietaken.

Doel:

- Minder copy/paste van losse blogposts,
- Meer herhaalbaarheid,
- Duidelijk onderscheid tussen:
  - wat “van Proxmox zelf” is,
  - en wat via community-scripts wordt gedaan.

---

## 1. Overzicht van relevante community-scripts

Belangrijkste scripts uit `community-scripts/ProxmoxVE` (globale indeling):

1. **PVE Post Install / Update scripts**
   - Repos fixen (enterprise → no-subscription),
   - Basis-apt-updates,
   - Eventueel klein tunen van PVE.

2. **LXC Helper-scripts**
   - Templates voor bekende applicaties in LXC-containers,
   - Bijvoorbeeld:
     - Debian/Ubuntu LXC met Docker,
     - specifieke apps (OpenWebUI, Arr-stack varianten, etc. – afhankelijk van repo).

3. **VM Helper-scripts**
   - Maken van cloud-init images,
   - Klaarzetten van standaard-VM’s.

We gebruiken deze scripts **selectief**, niet blind, en meestal in een
“sandbox-mentaliteit”: eerst op een testnode, dan pas op de rest.

---

## 2. Gebruik per fase

### 2.1. Fase “nieuwe node installatie”

Na een schone Proxmox-installatie:

1. Inloggen via SSH op de node.
2. Repos & updates regelen met PVE Post Install script:

   ```bash
   # voorbeeld, niet 1:1 overnemen zonder check
   bash -c "$(wget -qLO - https://community-scripts.github.io/ProxmoxVE/scripts/post-install.sh)"
   ```

3. Controleren:
   - `/etc/apt/sources.list` + PVE-lists zien er logisch uit,
   - `apt update && apt full-upgrade -y` draait clean.

**Regel:**  
Eerst dit script valideren op `pmx-qotom` (seed), daarna op de andere nodes.

---

### 2.2. Fase “infra-services opzetten”

Voor infra-VM’s en LXC’s (Wiki.js, Vaultwarden, Gitea, enz.):

- **Voorkeur:** eigen Debian/Ubuntu LXC of VM met handmatig beheer en
  `docker compose`, zodat je precies weet wat er draait.
- **Gebruik helper scripts:**
  - Als “bootstrap” om snel een basiscontainer neer te zetten
    (bijv. een generieke Debian LXC met bepaalde tunables).
  - Niet per se voor kant-en-klare applicatie-stacks die moeilijk te
    upgraden zijn buiten de scriptwereld om.

Praktisch:

- Voor een generieke Docker-host LXC:
  - kun je een script gebruiken dat:
    - Debian LXC maakt,
    - cgroup/privilege settings fixt,
    - Docker installeert.
- Voor specifieke applicaties (Arr-stack, OpenWebUI, etc.):
  - liever een eigen `docker-compose.yml` in je Git repo
    (`docker/stacks/...`), zodat versiebeheer **bij jou** ligt.

---

### 2.3. Fase “kwaliteits-of-leven taken”

Enkele helper-scripts kunnen later nog nuttig zijn voor:

- Cleanup-taken,
- Snapshot/backup-helpers,
- Migratie-scripts.

Regel:

- Draai ze nooit blind in productie,
- Probeer eerst op een niet-kritische VM of testnode,
- Documenteer in een runbook:
  - welke scriptversie je gebruikte,
  - met welke parameters.

---

## 3. Waar helper-scripts **niet** voor gebruiken

- Niet voor:
  - cluster-joins (`pvecm add` liever handmatig volgens runbook),
  - storage-config (ZFS/zpool/datasets liever zelf definiëren),
  - netwerk/VLAN-config (dit moet in lijn zijn met je OPNsense/VLAN-plan).

- Reden:
  - Dit zijn kernonderdelen van je architectuur,
  - je wilt precies weten wat er gebeurt,
  - en in je docs/runbooks 1-op-1 terugzien welke stappen gedaan zijn.

---

## 4. Workflow: installeren met helper-scripts + Git-documentatie

Aanbevolen werkwijze:

1. **Plan**:
   - In `docs/plan/*.md` (zoals dit document) staat:
     - wát je gaat doen,
     - wélke scripts je eventueel gebruikt.

2. **Uitvoering**:
   - Volg een runbook in `docs/runbooks/`.
   - Bijvoorbeeld:
     - `00-bootstrap-qotom-opnsense-hx310db` (in de toekomst),
     - `10-create-docker-host-lxc`.

3. **Loggen / ADR**:
   - Als je een helper-script inzet dat een significante verandering doet:
     - maak een korte ADR in `docs/decisions/`:
       - waarom dit script,
       - welke versie,
       - wat de alternatieven waren.
   - Dit voorkomt later “waarom is mijn systeem zo?”-momenten.

---

## 5. Concreet gebruik in jouw homelab

Samengevat per hosttype:

- **Qotom (`pmx-qotom`, vuurbuur)**:
  - PVE Post-install script: **JA** (voor repos/updates).
  - Applicatie-helpers: **zeer beperkt**, OPNsense zelf blijft handwerk.

- **HX310-DB (`pmx-hx310-db`, breintrein)**:
  - PVE Post-install: **JA**.
  - LXC-helper voor generieke Debian LXC (bijv. DB-management tools): **OK**.
  - Postgres/ Wiki.js/ Vaultwarden: liever eigen Docker/VM stacks uit Git.

- **HX310-ARR (`pmx-hx310-arr`, downloadboef)**:
  - PVE Post-install: **JA**.
  - Eventueel community-script om een *ARR-LXC te bootstrappen:
    - maar daarna zoveel mogelijk config in eigen `docker-compose.yml` zetten.

- **B450 Docker (`pmx-docker`, klusbus)**:
  - PVE Post-install: **JA**.
  - Docker-host-containers: helper-scripts mogen, maar:
    - Docker-stacks zelf blijven in `docker/stacks/` in je Git repo.

- **AI-Controller & AI-Worker (`pve-8845hs`, `pmx-ai-worker`)**:
  - PVE Post-install: **JA**.
  - AI-stacks (oneAPI, IPEX-LLM, OpenWebUI):
    - liever handmatig en/of via eigen scripts,
    - niet via generieke community-scripts, i.v.m. GPU-driver-gevoeligheid.

---

## 6. Checklist gebruik helper-scripts

- [ ] Op nieuwe nodes eerst het PVE Post-install script gedraaid.
- [ ] Per gebruik van een script:
  - [ ] kort genoteerd welk script,
  - [ ] welke versie/commit,
  - [ ] op welke node.
- [ ] Geen helper-scripts gebruikt voor:
  - [ ] cluster-join,
  - [ ] kern-storage-config,
  - [ ] kern-netwerk/VLAN-config.
