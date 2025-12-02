# Hardware Report: pve-5700g
Generated: 2025-11-30 16:03:30

## System Information
```
Hostname: pve-5700g.internal
Kernel: 6.17.2-2-pve
OS: Debian GNU/Linux 13 (trixie)
Uptime: up 7 minutes
Architecture: x86_64
```

## CPU Information
```
Architecture:                            x86_64
CPU(s):                                  16
On-line CPU(s) list:                     0-15
Vendor ID:                               AuthenticAMD
Model name:                              AMD Ryzen 7 5700G with Radeon Graphics
Thread(s) per core:                      2
Core(s) per socket:                      8
Socket(s):                               1
CPU(s) scaling MHz:                      68%
CPU max MHz:                             4673.8232
CPU min MHz:                             422.3340
NUMA node0 CPU(s):                       0-15
```

### Detailed CPU Info
```
processor	: 0
model name	: AMD Ryzen 7 5700G with Radeon Graphics
cpu MHz		: 3711.407
cache size	: 512 KB
processor	: 1
model name	: AMD Ryzen 7 5700G with Radeon Graphics
cpu MHz		: 3706.525
cache size	: 512 KB
processor	: 2
model name	: AMD Ryzen 7 5700G with Radeon Graphics
cpu MHz		: 4649.809
cache size	: 512 KB
processor	: 3
model name	: AMD Ryzen 7 5700G with Radeon Graphics
cpu MHz		: 3725.104
cache size	: 512 KB
processor	: 4
model name	: AMD Ryzen 7 5700G with Radeon Graphics
cpu MHz		: 2393.223
cache size	: 512 KB
```

## Memory Information
```
               total        used        free      shared  buff/cache   available
Mem:            30Gi       1.9Gi        29Gi        36Mi       160Mi        28Gi
Swap:             0B          0B          0B

Memory Details:
	Error Correction Type: None
	Type: Unknown
	Size: 16 GB
	Type: DDR4
	Speed: 2667 MT/s
	Manufacturer: Kingston
	Serial Number: 7824544B
	Configured Memory Speed: 2667 MT/s
	Module Manufacturer ID: Bank 2, Hex 0x98
	Memory Subsystem Controller Manufacturer ID: Unknown
	Non-Volatile Size: None
	Volatile Size: 16 GB
	Cache Size: None
	Logical Size: None
	Type: Unknown
	Size: 16 GB
	Type: DDR4
	Speed: 2667 MT/s
	Manufacturer: Kingston
	Serial Number: 5924545A
	Configured Memory Speed: 2667 MT/s
	Module Manufacturer ID: Bank 2, Hex 0x98
	Memory Subsystem Controller Manufacturer ID: Unknown
	Non-Volatile Size: None
	Volatile Size: 16 GB
	Cache Size: None
	Logical Size: None
```

## Network Interfaces
```
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp6s0           UP             
vmbr0            UP             192.168.10.14/16 fe80::7285:c2ff:fef8:4b85/64 

=== MAC Addresses ===
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 2: enp6s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master vmbr0 state UP mode DEFAULT group default qlen 1000
    link/ether 70:85:c2:f8:4b:85 brd ff:ff:ff:ff:ff:ff 3: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 70:85:c2:f8:4b:85 brd ff:ff:ff:ff:ff:ff
```

### Network Interface Details
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp6s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master vmbr0 state UP group default qlen 1000
    link/ether 70:85:c2:f8:4b:85 brd ff:ff:ff:ff:ff:ff
    altname enx7085c2f84b85
3: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 70:85:c2:f8:4b:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.14/16 scope global vmbr0
       valid_lft forever preferred_lft forever
    inet6 fe80::7285:c2ff:fef8:4b85/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
```

## Storage Devices
```
NAME          SIZE TYPE FSTYPE     MOUNTPOINT MODEL                     SERIAL
nvme2n1     476.9G disk                       Samsung SSD 960 PRO 512GB S3EWNX0K213926T
├─nvme2n1p1  1007K part                                                 
├─nvme2n1p2     1G part vfat                                            
└─nvme2n1p3   475G part zfs_member                                      
nvme1n1     953.9G disk                       Lexar SSD NM790 1TB       NKS515R002947P2202
nvme0n1     953.9G disk                       Lexar SSD NM790 1TB       NKS515R002966P2202
```

### Disk Details (Unmounted/Unpartitioned)
```
nvme2n1     476.9G disk            
├─nvme2n1p1  1007K part            
├─nvme2n1p2     1G part vfat       
└─nvme2n1p3   475G part zfs_member 
nvme1n1     953.9G disk            
nvme0n1     953.9G disk            

=== All Block Devices ===
Disk /dev/nvme2n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: Samsung SSD 960 PRO 512GB               
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/nvme1n1: 953.87 GiB, 1024209543168 bytes, 2000409264 sectors
Disk model: Lexar SSD NM790 1TB                     
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/nvme0n1: 953.87 GiB, 1024209543168 bytes, 2000409264 sectors
Disk model: Lexar SSD NM790 1TB                     
Sector size (logical/physical): 512 bytes / 512 bytes
```

### SMART Status
```
=== /dev/nvme2n1 ===
Model Number:                       Samsung SSD 960 PRO 512GB
Serial Number:                      S3EWNX0K213926T
Total NVM Capacity:                 512,110,190,592 [512 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          512,110,190,592 [512 GB]
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme1n1 ===
Model Number:                       Lexar SSD NM790 1TB
Serial Number:                      NKS515R002947P2202
Total NVM Capacity:                 1,024,209,543,168 [1.02 TB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          1,024,209,543,168 [1.02 TB]
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme0n1 ===
Model Number:                       Lexar SSD NM790 1TB
Serial Number:                      NKS515R002966P2202
Total NVM Capacity:                 1,024,209,543,168 [1.02 TB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          1,024,209,543,168 [1.02 TB]
SMART overall-health self-assessment test result: PASSED

```

## PCI Devices
```
03:00.0 USB controller: Advanced Micro Devices, Inc. [AMD] 400 Series Chipset USB 3.1 xHCI Compliant Host Controller (rev 01)
06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet Controller (rev 15)
07:00.0 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection (rev 01)
09:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd NVMe SSD Controller SM961/PM961/SM963
0a:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Cezanne [Radeon Vega Series / Radeon Vega Mobile Series] (rev c8)
0a:00.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Renoir Radeon High Definition Audio Controller
0a:00.3 USB controller: Advanced Micro Devices, Inc. [AMD] Renoir/Cezanne USB 3.1
0a:00.4 USB controller: Advanced Micro Devices, Inc. [AMD] Renoir/Cezanne USB 3.1
0a:00.6 Audio device: Advanced Micro Devices, Inc. [AMD] Family 17h/19h/1ah HD Audio Controller
0b:00.0 SATA controller: Advanced Micro Devices, Inc. [AMD] FCH SATA Controller [AHCI mode] (rev 81)
0b:00.1 SATA controller: Advanced Micro Devices, Inc. [AMD] FCH SATA Controller [AHCI mode] (rev 81)
```

### Detailed PCI Info
```
06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet Controller (rev 15)
	Subsystem: ASRock Incorporation Motherboard (one of many)
	Flags: bus master, fast devsel, latency 0, IRQ 37, IOMMU group 1
	I/O ports at e000 [size=256]
	Memory at fca04000 (64-bit, non-prefetchable) [size=4K]
	Memory at fca00000 (64-bit, non-prefetchable) [size=16K]
--
07:00.0 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection (rev 01)
	Subsystem: Intel Corporation Ethernet Server Adapter X520-1
	Flags: fast devsel, IRQ 35, IOMMU group 1
	Memory at fc880000 (64-bit, non-prefetchable) [size=512K]
	I/O ports at d000 [size=32]
	Memory at fc900000 (64-bit, non-prefetchable) [size=16K]
	Expansion ROM at fc800000 [disabled] [size=512K]
```

## USB Devices
```
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 005 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 006 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```

## ZFS Pools (if any)
```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
rpool   472G  2.73G   469G        -         -     0%     0%  1.00x    ONLINE  -

  pool: rpool
 state: ONLINE
config:

	NAME                               STATE     READ WRITE CKSUM
	rpool                              ONLINE       0     0     0
	  nvme-eui.0025385281b1273f-part3  ONLINE       0     0     0

errors: No known data errors
```

## LVM Information (if any)
```


```

## Proxmox VE Information
```
proxmox-ve: 9.1.0 (running kernel: 6.17.2-2-pve)
pve-manager: 9.1.1 (running version: 9.1.1/42db4a6cf33dac83)
proxmox-kernel-helper: 9.0.4
proxmox-kernel-6.17.2-2-pve-signed: 6.17.2-2
proxmox-kernel-6.17: 6.17.2-2
proxmox-kernel-6.14.11-4-pve-signed: 6.14.11-4
proxmox-kernel-6.14: 6.14.11-4
proxmox-kernel-6.14.8-2-pve-signed: 6.14.8-2
amd64-microcode: 3.20250311.1
ceph-fuse: 19.2.3-pve1
corosync: 3.1.9-pve2
criu: 4.1.1-1
frr-pythontools: 10.3.1-1+pve4
ifupdown2: 3.3.0-1+pmx11
ksm-control-daemon: 1.5-1
libjs-extjs: 7.0.0-5
libproxmox-acme-perl: 1.7.0
libproxmox-backup-qemu0: 2.0.1
libproxmox-rs-perl: 0.4.1
libpve-access-control: 9.0.4
libpve-apiclient-perl: 3.4.2
libpve-cluster-api-perl: 9.0.7
libpve-cluster-perl: 9.0.7
libpve-common-perl: 9.0.15
libpve-guest-common-perl: 6.0.2
libpve-http-server-perl: 6.0.5
libpve-network-perl: 1.2.3
libpve-rs-perl: 0.11.3
libpve-storage-perl: 9.1.0
libspice-server1: 0.15.2-1+b1
lvm2: 2.03.31-2+pmx1
lxc-pve: 6.0.5-3
lxcfs: 6.0.4-pve1
novnc-pve: 1.6.0-3
proxmox-backup-client: 4.1.0-1
proxmox-backup-file-restore: 4.1.0-1
proxmox-backup-restore-image: 1.0.0
proxmox-firewall: 1.2.1
proxmox-kernel-helper: 9.0.4
proxmox-mail-forward: 1.0.2
proxmox-mini-journalreader: 1.6
proxmox-offline-mirror-helper: 0.7.3
proxmox-widget-toolkit: 5.1.2
pve-cluster: 9.0.7
pve-container: 6.0.18
pve-docs: 9.1.1
pve-edk2-firmware: 4.2025.05-2
pve-esxi-import-tools: 1.0.1
pve-firewall: 6.0.4
pve-firmware: 3.17-2
pve-ha-manager: 5.0.8
pve-i18n: 3.6.4
pve-qemu-kvm: 10.1.2-4
pve-xtermjs: 5.5.0-3
qemu-server: 9.1.0
smartmontools: 7.4-pve1
spiceterm: 3.4.1
swtpm: 0.8.0+pve3
vncterm: 1.9.1
zfsutils-linux: 2.3.4-pve1
```

### Proxmox Storage Configuration
```
Name             Type     Status     Total (KiB)      Used (KiB) Available (KiB)        %
local             dir     active       476728192             128       476728064    0.00%
local-zfs     zfspool     active       476728164              96       476728068    0.00%
```

### Proxmox Network Configuration
```
auto lo
iface lo inet loopback

iface enp6s0 inet manual

auto vmbr0
iface vmbr0 inet static
	address 192.168.10.14/16
	gateway 192.168.1.1
	bridge-ports enp6s0
	bridge-stp off
	bridge-fd 0

iface enp7s0 inet manual


source /etc/network/interfaces.d/*
```

## Hardware Sensors (if available)
```
lm-sensors not installed
```

## DMI/SMBIOS Information
```
=== System ===
	Manufacturer: To Be Filled By O.E.M.
	Product Name: To Be Filled By O.E.M.
	Serial Number: To Be Filled By O.E.M.
	UUID: f8c28570-854b-0000-0000-000000000000

=== BIOS ===
	Vendor: American Megatrends Inc.
	Version: P5.70
	Release Date: 10/20/2022

=== Baseboard ===
	Manufacturer: ASRock
	Product Name: B450M Pro4
	Serial Number: M80-C8019400648
```

---
Report generated on 2025-11-30 16:03:30
