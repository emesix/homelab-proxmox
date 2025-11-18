# Automation

This folder is reserved for scripts and tools that help automate the homelab deployment and maintenance.

Conventions:

- Scripts should be understandable and maintainable by “future you”.
- Destructive actions (disk wipes, major network changes) must:
  - clearly document what they do,
  - support `--dry-run` or similar,
  - require confirmation or `--force`.

At this time, this folder only documents the intended structure. Actual scripts can be added gradually as runbooks are tested and stabilised.
