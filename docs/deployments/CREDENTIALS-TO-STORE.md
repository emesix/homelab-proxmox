# Credentials to Store in Vaultwarden

**IMPORTANT:** After creating your Vaultwarden account, store these credentials immediately.

## Access Vaultwarden

**URL:** http://192.168.10.21  
**Create your account first**, then add these credentials.

---

## PostgreSQL Database Passwords

### Vaultwarden Database
- **Service:** PostgreSQL - Vaultwarden Database
- **Host:** 192.168.10.20:5432
- **Database:** vaultwarden
- **Username:** vaultwarden
- **Password:** (content of `/tmp/pw1`)
  ```bash
  cat /tmp/pw1
  ```

### Gitea Database
- **Service:** PostgreSQL - Gitea Database
- **Host:** 192.168.10.20:5432
- **Database:** gitea
- **Username:** gitea
- **Password:** (content of `/tmp/pw2`)
  ```bash
  cat /tmp/pw2
  ```

### Wiki.js Database
- **Service:** PostgreSQL - Wiki.js Database
- **Host:** 192.168.10.20:5432
- **Database:** wikijs
- **Username:** wikijs
- **Password:** (content of `/tmp/pw3`)
  ```bash
  cat /tmp/pw3
  ```

---

## Vaultwarden Admin Token

- **Service:** Vaultwarden Admin Panel
- **URL:** http://192.168.10.21/admin
- **Admin Token:** (content of `/tmp/vaultwarden-admin-token`)
  ```bash
  cat /tmp/vaultwarden-admin-token
  ```

---

## LXC Container Root Passwords

### PostgreSQL Container (CT101)
- **Service:** LXC CT101 - PostgreSQL (pg-brein)
- **IP:** 192.168.10.20
- **Username:** root
- **Password:** NikonD90 (staging)

### Vaultwarden Container (CT102)
- **Service:** LXC CT102 - Vaultwarden (kluisbaas)
- **IP:** 192.168.10.21
- **Username:** root
- **Password:** NikonD90 (staging)

---

## Proxmox Hosts (Staging Passwords)

### pve-qotom01
- **IP:** 192.168.10.11
- **Username:** root
- **Password:** NikonD90 (staging)

### pve-hx310-db
- **IP:** 192.168.10.12
- **Username:** root
- **Password:** NikonD90 (staging)

### pve-hx310-arr
- **IP:** 192.168.10.13
- **Username:** root
- **Password:** NikonD90 (staging)

### pve-5700g
- **IP:** 192.168.10.14
- **Username:** root
- **Password:** NikonD90 (staging)

### pve-8845hs
- **IP:** 192.168.10.15
- **Username:** root
- **Password:** NikonD90 (staging)

### pve-x2686-x2
- **IP:** 192.168.10.16
- **Username:** root
- **Password:** NikonD90 (staging)

---

## SSH Keys

### Workstation SSH Key
- **Service:** Workstation SSH Key (emesix)
- **Public Key:** ~/.ssh/id_ed25519.pub
- **Private Key:** ~/.ssh/id_ed25519
- **Note:** Already deployed to all Proxmox hosts for passwordless access

---

## After Storing All Credentials

1. **Export your Vaultwarden vault** as encrypted backup
2. **Store the backup** in a secure location (off-site recommended)
3. **Test recovery** by importing on another device
4. **Disable signups** in Vaultwarden (see vaultwarden-ct102.md)
5. **Delete temporary password files** (optional - keep until fully verified):
   ```bash
   # On workstation
   rm /tmp/pw1 /tmp/pw2 /tmp/pw3 /tmp/vaultwarden-admin-token
   
   # On pve-hx310-db
   ssh root@192.168.10.12 "rm /tmp/pw1 /tmp/pw2 /tmp/pw3"
   ```

---

## Security Notes

- These are **staging environment credentials** - will be changed for production
- Store your **Vaultwarden master password** in a secure, offline location
- Enable **2FA** on Vaultwarden account after initial setup
- Regular **vault exports** should be part of backup strategy
