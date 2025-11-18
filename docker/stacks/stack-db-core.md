# Docker Stack: DB Core (Postgres, Vaultwarden, Wiki.js, Git)

## Host

- Primary: `pve-hx310-db` (OnLogic HX310, 64 GB RAM, 1 TB NVMe).

## Services

- PostgreSQL
- Vaultwarden
- Wiki.js
- Git service (Gitea / Forgejo)

## Purpose

Centralise core data and documentation services on a stable, low-power, always-on node. This stack provides:

- Authentication/credentials (Vaultwarden).
- Documentation (Wiki.js).
- Git hosting and mirrors.
- Datastore for all of the above plus future internal services.

Detailed docker-compose (or LXC/VM specs) can be added here later.
