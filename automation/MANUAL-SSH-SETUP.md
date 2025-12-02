# Manual SSH Key Setup Guide

If the automated script doesn't work or you prefer to set up SSH keys manually, follow these steps.

## Your SSH Public Key

Copy this key - you'll paste it on each Proxmox node:

```
ssh-ed25519 AAAAC3Nz... your-public-key-comment
```

## Option 1: Use ssh-copy-id (Recommended)

Run this command for each node:

```bash
# For pve-qotom01
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.10.11

# For pve-hx310-db
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.10.12

# For pve-hx310-arr
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.10.13

# For pve-5700g
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.10.14

# For pve-8845hs
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.10.15

# For pve-x2686-x2
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.10.16
```

## Option 2: Manual Copy-Paste

If ssh-copy-id doesn't work, do this for each node:

1. SSH into the node:
   ```bash
   ssh root@192.168.10.11  # change IP for each node
   ```

2. Create the .ssh directory if it doesn't exist:
   ```bash
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   ```

3. Add your public key to authorized_keys:
   ```bash
   echo "ssh-ed25519 AAAAC3Nz... your-public-key-comment
   chmod 600 ~/.ssh/authorized_keys
   ```

4. Exit and test:
   ```bash
   exit
   ssh root@192.168.10.11 "hostname"  # Should work without password
   ```

## Option 3: One-liner per Node

```bash
# pve-qotom01
ssh root@192.168.10.11 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo "ssh-ed25519 AAAAC3Nz... your-public-key-comment

# pve-hx310-db
ssh root@192.168.10.12 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo "ssh-ed25519 AAAAC3Nz... your-public-key-comment

# pve-hx310-arr
ssh root@192.168.10.13 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo "ssh-ed25519 AAAAC3Nz... your-public-key-comment

# pve-5700g
ssh root@192.168.10.14 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo "ssh-ed25519 AAAAC3Nz... your-public-key-comment

# pve-8845hs
ssh root@192.168.10.15 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo "ssh-ed25519 AAAAC3Nz... your-public-key-comment

# pve-x2686-x2
ssh root@192.168.10.16 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo "ssh-ed25519 AAAAC3Nz... your-public-key-comment
```

## Verify All Nodes

After setting up, verify passwordless access works:

```bash
for ip in 192.168.10.11 192.168.10.12 192.168.10.13 192.168.10.14 192.168.10.15 192.168.10.16; do
    echo -n "$ip: "
    ssh -o BatchMode=yes root@$ip "hostname" && echo "✓ OK" || echo "✗ Failed"
done
```

## Troubleshooting

### Permission denied even after adding key

Check SELinux context (unlikely on Proxmox but possible):
```bash
restorecon -R ~/.ssh
```

### Check SSH configuration on the node

```bash
# Make sure PubkeyAuthentication is enabled
grep PubkeyAuthentication /etc/ssh/sshd_config
```

### Check authorized_keys file

```bash
# Should show your key
cat ~/.ssh/authorized_keys
```

### Check file permissions

```bash
# Should be: drwx------ (700) for .ssh directory
# Should be: -rw------- (600) for authorized_keys file
ls -la ~/.ssh/
```
