#!/bin/bash
#
# proxmox-postinstall.sh
#
# Minimal post-install script for Proxmox nodes in the homelab.
#
# - Uses the current hostname as canonical name
# - Sets the domain to "internal" (can be overridden via MY_DOMAIN env)
# - Rewrites /etc/hosts with the cluster IP/host mapping
# - Ensures /root/.ssh exists for later key distribution
#

set -euo pipefail

# Use the current short hostname from the system
MY_HOSTNAME="$(hostname -s)"

# Default domain; can be overridden: e.g. MY_DOMAIN=lab.local ./proxmox-postinstall.sh
MY_DOMAIN="${MY_DOMAIN:-internal}"
MY_FQDN="${MY_HOSTNAME}.${MY_DOMAIN}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

echo "==> Detected hostname: ${MY_HOSTNAME}"
echo "==> Using FQDN:        ${MY_FQDN}"

echo "==> Writing /etc/hosts"
cat >/etc/hosts <<EOF
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback

# Local hostname (this host)
127.0.1.1       ${MY_FQDN} ${MY_HOSTNAME}

# Proxmox cluster (hypervisors / management IPs)
192.168.10.11   pve-qotom01.internal    pve-qotom01
192.168.10.12   pve-hx310-db.internal   pve-hx310-db
192.168.10.13   pve-hx310-arr.internal  pve-hx310-arr
192.168.10.14   pve-5700g.internal      pve-5700g
192.168.10.15   pve-8845hs.internal     pve-8845hs
192.168.10.16   pve-x2686-x2.internal   pve-x2686-x2

# Storage
192.168.20.11   nas-main.internal       nas-main
EOF

echo "==> Basic checks"
echo "Hostname  : $(hostname)"
echo "FQDN      : $(hostname -f)"
echo "Lookup via getent:"
getent hosts "${MY_HOSTNAME}" || true
getent hosts "${MY_FQDN}"     || true

echo "==> Preparing /root/.ssh (for SSH keys)"
mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "==> Restarting SSH daemon (if possible)"
systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true

echo "Post-install for ${MY_HOSTNAME} completed."
