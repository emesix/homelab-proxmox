#!/bin/bash
#
# setup-ssh-keys.sh
#
# Run this script on your management workstation (not on Proxmox) to:
# - Create an SSH key (if not present)
# - Push the public key to all Proxmox nodes for passwordless root SSH
#

set -euo pipefail

# List of Proxmox nodes (FQDNs)
HOSTS=(
  "pve-qotom01.internal"
  "pve-hx310-db.internal"
  "pve-hx310-arr.internal"
  "pve-5700g.internal"
  "pve-8845hs.internal"
  "pve-x2686-x2.internal"
)

KEYFILE="${HOME}/.ssh/id_ed25519"

echo "==> Checking for existing SSH key: ${KEYFILE}"
if [[ ! -f "${KEYFILE}" ]]; then
  echo "No key found, generating a new ed25519 key..."
  ssh-keygen -t ed25519 -f "${KEYFILE}" -C "homelab@$(hostname -s)"
fi

for host in "${HOSTS[@]}"; do
  echo "==> Copying SSH key to root@${host}"
  ssh-copy-id -i "${KEYFILE}.pub" root@"${host}"
done

echo "==> Testing passwordless SSH:"
for host in "${HOSTS[@]}"; do
  echo "--- ${host} ---"
  if ssh -o BatchMode=yes root@"${host}" "hostname && hostname -f"; then
    echo "OK: SSH to ${host} works without password."
  else
    echo "!! WARNING: SSH to ${host} still requires a password or failed."
  fi
done

echo "All done. If most tests show 'OK', you can safely disable root password logins later."
