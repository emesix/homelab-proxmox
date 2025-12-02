# Service Inventory & Placement

Dit document beschrijft **welke services** waar gaan draaien, met:

- Technische hostnaam (DNS / Proxmox)
- Bijnaam (“straatnaam”) voor documentatie en AI
- Belangrijkste services per host
- Type (VM / LXC / Docker / bare metal)
- Installatiemethode (handmatig / helper-script / anders)

Hosts zitten in het interne domein: `*.local.emesix.nl`.

---

## Overzicht per host

| Host hardware        | Technische hostnaam                    | Bijnaam        | Hoofdrol                            |
|----------------------|----------------------------------------|----------------|-------------------------------------|
| Qotom 1U             | `pmx-qotom.local.emesix.nl`            | **vuurbuur**   | LAN management & infra              |
| HX310-1 (DB)         | `pmx-hx310-db.local.emesix.nl`         | **breintrein** | Databases & core services           |
| HX310-2 (*ARR)       | `pmx-hx310-arr.local.emesix.nl`        | **downloadboef** | Mediaautomation & downloads       |
| B450 5700G           | `pmx-docker.local.emesix.nl`           | **klusbus**    | Zware Docker workloads              |
| CW-NAS-AMD (FP7)     | `pmx-ai-ctl.local.emesix.nl`           | **hoofdstuk**  | AI-controller & orkestratie         |
| X99 dual Xeon        | `pmx-ai-worker.local.emesix.nl`        | **denkdoos**   | AI-worker / GPU compute             |
| Unraid NAS           | `nas-unraid.local.emesix.nl`           | **schuifkast** | Storage, backups & media opslag     |

---

## 1. Qotom 1U – `pmx-qotom` – **vuurbuur**

**Rol:** LAN-management, router/firewall, netboot, WiFi-mgmt, printing, config-backups.

- Technische host: `pmx-qotom.local.emesix.nl`
- Bijnaam: **vuurbuur** (firewall-buurman)

### Services op vuurbuur

| Service             | DNS / hostnaam                              | Bijnaam       | Type | Installatie        |
|---------------------|---------------------------------------------|---------------|------|--------------------|
| OPNsense firewall   | `fw-vuurbuur.local.emesix.nl`               | **wijkagent** | VM   | ISO, handmatig     |
| Netboot.xyz         | `bootkroket.local.emesix.nl`                | **bootkroket**| LXC  | Handmatig / script |
| OpenWISP / WiFi mgmt| `wifi-coach.local.emesix.nl`                | **wifi-coach**| LXC/VM + Docker | Handmatig  |
| Notifiarr           | `pingpoes.local.emesix.nl`                  | **pingpoes**  | LXC/VM + Docker | Handmatig  |
| CUPS printserver    | `inktvis.local.emesix.nl`                   | **inktvis**   | LXC  | Handmatig (Debian) |
| Config-backups      | `kluisje.local.emesix.nl`                   | **kluisje**   | Scripts / LXC | Custom scripts |

**Opmerkingen:**

- OPNsense krijgt PCI passthrough van NICs/SFP.
- Netboot.xyz idealiter in een dedicated Debian LXC, met TFTP/PXE richting LAN.
- Backups van OPNsense en Proxmox-configs gaan naar `schuifkast` (NAS) via `kluisje`.

---

## 2. HX310-1 – `pmx-hx310-db` – **breintrein**

**Rol:** centrale datadiensten en “serieuze” core services.

- Technische host: `pmx-hx310-db.local.emesix.nl`
- Bijnaam: **breintrein**

### Services op breintrein

| Service          | DNS / hostnaam                          | Bijnaam         | Type        | Installatie                       |
|------------------|-----------------------------------------|-----------------|-------------|-----------------------------------|
| PostgreSQL       | `pg-brein.local.emesix.nl`              | **datakluizenaar** | VM (aanr.) | Handmatig (strak geconfigureerd) |
| Wiki.js          | `wiki-brein.local.emesix.nl`            | **weetal**      | Docker in VM of LXC | Handmatig/Docker-compose |
| Vaultwarden      | `kluisbaas.local.emesix.nl`             | **kluisbaas**   | LXC/VM + Docker | Handmatig of helper-script       |
| Gitea/Forgejo    | `codekroeg.local.emesix.nl`             | **codekroeg**   | LXC (aanr.) | Helper-script of handmatig       |

**Opmerkingen:**

- PostgreSQL is “tier 0” – liefst eigen VM met dedicated ZFS-dataset.
- Wiki.js en Vaultwarden leunen op Postgres (`pg-brein`).
- Gitea/Forgejo host Git-repo’s voor infra en documentatie.

---

## 3. HX310-2 – `pmx-hx310-arr` – **downloadboef**

**Rol:** media-automation en downloadstack.

- Technische host: `pmx-hx310-arr.local.emesix.nl`
- Bijnaam: **downloadboef**

### Services op downloadboef

| Service            | DNS / hostnaam                                       | Bijnaam       | Type         | Installatie                               |
|--------------------|------------------------------------------------------|---------------|--------------|-------------------------------------------|
| Radarr             | `radarr.downloadboef.local.emesix.nl`                | **filmfreak** | LXC/Docker   | Helper-scripts of *ARR-stack Docker       |
| Sonarr             | `sonarr.downloadboef.local.emesix.nl`                | **seriejunk** | LXC/Docker   | Idem                                      |
| Lidarr             | `lidarr.downloadboef.local.emesix.nl`                | **beatbox**   | LXC/Docker   | Idem                                      |
| Prowlarr/Bazarr…   | `arr-gang.downloadboef.local.emesix.nl`              | **arr-gang**  | LXC/Docker   | Idem                                      |
| NZB/torrent client | `slurpbakkie.local.emesix.nl`                        | **slurpbakkie** | LXC/Docker | Docker/Compose op deze node               |

**Opmerkingen:**

- Data en completed downloads gaan naar shares op **schuifkast**.
- Deze node is CPU/IO-light vergeleken met AI/DB – prima voor veel kleine containers.

---

## 4. B450 5700G – `pmx-docker` – **klusbus**

**Rol:** generieke Docker worker voor zwaardere backend-taken.

- Technische host: `pmx-docker.local.emesix.nl`
- Bijnaam: **klusbus**

### Services op klusbus

| Service/rol           | DNS / hostnaam                          | Bijnaam        | Type      | Installatie                |
|-----------------------|-----------------------------------------|----------------|-----------|----------------------------|
| Docker host           | `stapelbak.klusbus.local.emesix.nl`     | **stapelbak**  | Bare metal / VM | Handmatig (Docker + compose) |
| CI / automation       | n.v.t. (verschillende containers)       | **pipelinepiet** | Docker   | Per stack/compose         |
| Zware tools/indexers  | n.v.t.                                  | **hardeharker** | Docker    | Per tool                  |

**Opmerkingen:**

- Deze host is ideaal voor alles wat CPU-intensief is maar geen GPU nodig heeft.
- Gebruik labels/taints in je orkestratie (als je later Swarm/K8s wilt) op basis van **klusbus**.

---

## 5. CW-NAS-AMD – `pmx-ai-ctl` – **hoofdstuk**

**Rol:** AI-controller, orchestrator en API-router.

- Technische host: `pmx-ai-ctl.local.emesix.nl`
- Bijnaam: **hoofdstuk**

### Services op hoofdstuk

| Service                | DNS / hostnaam                               | Bijnaam        | Type           | Installatie                            |
|------------------------|----------------------------------------------|----------------|----------------|----------------------------------------|
| Open WebUI             | `praatpaal.local.emesix.nl`                  | **praatpaal**  | LXC (aanr.)    | Helper-script (OpenWebUI LXC)         |
| Vector DB (Chroma/Qdrant/pgvector) | `geheugengeus.local.emesix.nl`   | **geheugengeus** | Docker/LXC   | Handmatig/Docker-compose              |
| Orchestrator (Mem0/MCP/agent) | `regisseur.hoofdstuk.local.emesix.nl` | **regisseur** | Docker / service stack | Handmatig                              |
| AI/API router / gateway | `verkeerstoren.local.emesix.nl`            | **verkeerstoren** | Docker/LXC  | Handmatig                             |

**Opmerkingen:**

- **hoofdstuk** praat zowel naar buiten (OpenRouter/OpenAI) als naar **denkdoos**.
- Hier komt ook de integratie met Wiki.js, Git, logs en eventueel MCP-tools.

---

## 6. X99 dual Xeon – `pmx-ai-worker` – **denkdoos**

**Rol:** AI GPU compute node.

- Technische host: `pmx-ai-worker.local.emesix.nl`
- Bijnaam: **denkdoos**

### Services op denkdoos

| Service/rol                  | DNS / hostnaam                           | Bijnaam        | Type           | Installatie                      |
|------------------------------|------------------------------------------|----------------|----------------|----------------------------------|
| Model-serving (LLM)          | `modelmolen.denkdoos.local.emesix.nl`    | **modelmolen** | Bare metal/VM  | Handmatig (oneAPI, IPEX-LLM etc.) |
| Embedding worker             | `woordenwolf.denkdoos.local.emesix.nl`   | **woordenwolf**| Bare metal/VM  | Handmatig                        |
| Batch / zware inference jobs | n.v.t.                                   | **zwetser**    | Jobs / scripts | Handmatig                        |

**Opmerkingen:**

- Hier is kernel/driver-afstemming belangrijk voor de Arc GPU’s.
- Deze node expose je idealiter alleen via interne API’s naar **hoofdstuk**.

---

## 7. Unraid NAS – `nas-unraid` – **schuifkast**

**Rol:** centrale storage, backups, media-opslag, eventueel downloaders.

- Technische host: `nas-unraid.local.emesix.nl`
- Bijnaam: **schuifkast**

### Services op schuifkast

| Service           | DNS / hostnaam                                   | Bijnaam        | Type       | Installatie                |
|-------------------|--------------------------------------------------|----------------|------------|----------------------------|
| File shares       | `boekenplank.schuifkast.local.emesix.nl`        | **boekenplank**| SMB/NFS    | Unraid                     |
| Backup share      | `backuplade.schuifkast.local.emesix.nl`         | **backuplade** | SMB/NFS    | Unraid                     |
| Media opslag      | `medialade.schuifkast.local.emesix.nl`          | **medialade**  | SMB/NFS    | Unraid                     |
| Downloadstack (optioneel) | `downloadschuur.schuifkast.local.emesix.nl` | **downloadschuur** | Docker op Unraid | Unraid apps/docker |

**Opmerkingen:**

- Proxmox-backups, OPNsense-backups en config-dumps landen in `backuplade`.
- *ARR-services op **downloadboef** schrijven hun data naar `medialade` en/of `downloadschuur`.

---

## 8. Gebruik van bijnamen in documentatie

Aanbevolen aanpak:

- **Wiki.js / docs**
  - Hoofdpagina per host:  
    `pmx-hx310-db (breintrein)` – rol, hardware, ZFS-layout, services.
  - Servicelijsten verwijzen zowel naar technische naam als bijnaam:
    - “Wiki.js draait op **breintrein** (`pmx-hx310-db`).”
- **Proxmox labels**
  - Node description:  
    `vuurbuur – LAN management / OPNsense`
  - VM/LXC tags met bijnamen zoals `praatpaal`, `slurpbakkie`, `kluisbaas`.
- **AI Orchestrator**
  - In prompts kun je letterlijk opschrijven:  
    “Stuur zware GPU-taken naar **denkdoos** en lichte RAG/coordination via **hoofdstuk**.”

Deze naamlaag maakt je homelab menselijk leesbaar zonder de technische structuur kwijt te raken.
