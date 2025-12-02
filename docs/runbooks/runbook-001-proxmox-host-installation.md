# Runbook-001: Proxmox Host Installation (Staging Network)

## Purpose

Provide a repeatable set of steps to:

- Install Proxmox VE on a bare-metal host.
- Attach it to the staging network (`10.10.0.0/16`).
- Prepare it for later inclusion in a Proxmox cluster.

This runbook intentionally avoids over-automating:
- You can copy/paste commands step-by-step.
- Later, parts of this can be wrapped in scripts under `automation/`.

## Prerequisites

- Staging OPNsense router up and running.
- Staging LAN: `10.10.0.1/16`.
- DHCP reservations configured for the host MAC address, mapping it to:
  - its future management IP inside `10.10.200.0/24`.

Example:
- Qotom: `10.10.200.10`.
- HX310-DB: `10.10.200.20`.
- HX310-ARR: `10.10.200.21`.
- etc.

## Steps

1. **Install Proxmox from ISO**

   - Boot from the official Proxmox VE ISO.
   - Follow installer defaults except:
     - Use ZFS root if desired (depending on hardware).
     - Set a temporary password for `root@pam`.
   - Confirm that the installer chooses a correct NIC and IP (from DHCP if used).

2. **Initial Login**

   - After reboot, access:
     - `https://10.10.200.X:8006/` from a browser.
   - Log in as `root@pam` with the password you chose during install.

3. **Set Repository Settings**

   Using the Proxmox GUI or CLI:
   - Disable enterprise repo (if not using a subscription).
   - Enable `pve-no-subscription` repo.
   - Optionally install a dark theme (cosmetic).

   These steps can later be automated with community helper scripts, but this runbook assumes manual changes are acceptable for the first host.

4. **Configure Time, NTP, and DNS**

   - Ensure correct timezone.
   - Configure DNS servers (e.g. pointing at OPNsense or upstream providers).
   - Make sure `apt update` works properly.

5. **Verify Network Settings**

   - Confirm the host is reachable:
     - From your workstation via `ssh root@10.10.200.X`.
   - Document NIC mappings and bridges for this host in `hosts/<host>.md`.

6. **Repeat for Each Proxmox Host**

   For each hardware node:

   - Qotom (LAN management / OPNsense host).
   - HX310-DB.
   - HX310-ARR.
   - pve-8845hs AI-controller.
   - X99 AI-worker.
   - Ryzen Docker worker.

## Notes

- Cluster creation, node joining, and more advanced storage/networking are handled in separate runbooks.
- Keep this runbook simple so it remains valid even if automation later improves.
