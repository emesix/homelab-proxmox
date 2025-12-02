# Proxmox API Access

## Overview
Proxmox VE on Qotom (192.168.10.11) provides a REST API for programmatic control and automation.

## API Token

### Created Token
- **Token ID**: `root@pam!automation`
- **Token Secret**: `<see password manager entry \"Proxmox API automation token\">`
- **Created**: 2025-11-30

### Token Creation Command
```bash
pveum token add root@pam!automation
```

**Note**: Token names must be alphanumeric only (no hyphens, underscores, or special characters).

## API Endpoint
- **Base URL**: `https://192.168.10.11:8006/api2/json`
- **Web Interface**: `https://192.168.10.11:8006`

## Authentication

### Using cURL
```bash
curl -k -H "Authorization: PVEAPIToken=root@pam!automation=<YOUR_TOKEN_SECRET>" \
  https://192.168.10.11:8006/api2/json/nodes
```

### Using Python (proxmoxer)
```python
from proxmoxer import ProxmoxAPI

proxmox = ProxmoxAPI(
    '192.168.10.11',
    user='root@pam',
    token_name='automation',
    token_value='<YOUR_TOKEN_SECRET>',
    verify_ssl=False
)

# Example: List nodes
nodes = proxmox.nodes.get()
```

## Common API Operations

### List Nodes
```bash
GET /api2/json/nodes
```

### List VMs on a Node
```bash
GET /api2/json/nodes/{node}/qemu
```

### List Containers on a Node
```bash
GET /api2/json/nodes/{node}/lxc
```

### Start a VM
```bash
POST /api2/json/nodes/{node}/qemu/{vmid}/status/start
```

### Stop a VM
```bash
POST /api2/json/nodes/{node}/qemu/{vmid}/status/stop
```

## Security Notes
- Token has full root privileges
- Store the secret securely (consider using environment variables or secrets management)
- The secret cannot be retrieved after creation - save it immediately
- For production use, consider creating tokens with limited permissions

## Managing Tokens

### List Tokens
```bash
pveum user token list root@pam
```

### Delete Token
```bash
pveum user token remove root@pam!automation
```

### Create Token with Limited Permissions
```bash
# Create a user with specific role
pveum user add automation@pam
pveum acl modify / --users automation@pam --roles PVEVMUser

# Create token for that user
pveum token add automation@pam!limited
```

## Resources
- [Proxmox VE API Documentation](https://pve.proxmox.com/pve-docs/api-viewer/)
- [proxmoxer Python Library](https://github.com/proxmoxer/proxmoxer)
