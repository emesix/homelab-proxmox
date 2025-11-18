# Docker Stack: Media / *ARR

## Host

- Primary: `pve-hx310-arr` (OnLogic HX310, 32 GB RAM, 1 TB NVMe + 1 TB SATA).

## Services

- Radarr
- Sonarr
- Lidarr
- Indexers and supporting frontends

## Purpose

Provide media automation and library management, offloading work from the main NAS and keeping frontend-heavy media services on a dedicated, low-power box.

Storage for actual media files is provided by the unRAID NAS over backend network shares.
