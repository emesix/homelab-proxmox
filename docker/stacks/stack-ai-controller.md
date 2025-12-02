# Docker Stack: AI Controller

## Host

- Primary: `pve-cwnas-ai` (CW-NAS-AMD-FP7-20G, Ryzen 7 8845HS, 64 GB RAM).

## Services

- Open WebUI (or similar AI web frontend).
- Embedding/vectorisation service.
- Vector database (e.g. Qdrant, pgvector-backed service, or similar).
- AI/API manager / router:
  - routes jobs to:
    - local Bronze models,
    - local Silver worker (when online),
    - external Gold APIs.

## Purpose

Central point for:

- orchestrating AI tasks,
- integrating with Wiki.js and Git for context,
- providing a stable always-on control-plane for AI-driven automation.

Implementation details (stack choice, exact tools) will be refined in future docs and not hard-coded here.
