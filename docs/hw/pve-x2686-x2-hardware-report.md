# Hardware Report: pve-x2686-x2
Generated: 2025-11-30 16:03:35

## System Information
```
Hostname: pve-x2686-x2.internal
Kernel: 6.17.2-2-pve
OS: Debian GNU/Linux 13 (trixie)
Uptime: up 5 minutes
Architecture: x86_64
```

## CPU Information
```
Architecture:                            x86_64
CPU(s):                                  72
On-line CPU(s) list:                     0-71
Vendor ID:                               GenuineIntel
Model name:                              Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz
Thread(s) per core:                      2
Core(s) per socket:                      18
Socket(s):                               2
CPU(s) scaling MHz:                      96%
CPU max MHz:                             3000.0000
CPU min MHz:                             1200.0000
NUMA node0 CPU(s):                       0-17,36-53
NUMA node1 CPU(s):                       18-35,54-71
```

### Detailed CPU Info
```
processor	: 0
model name	: Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz
cpu MHz		: 2639.720
cache size	: 46080 KB
processor	: 1
model name	: Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz
cpu MHz		: 2695.906
cache size	: 46080 KB
processor	: 2
model name	: Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz
cpu MHz		: 3000.000
cache size	: 46080 KB
processor	: 3
model name	: Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz
cpu MHz		: 3000.000
cache size	: 46080 KB
processor	: 4
model name	: Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz
cpu MHz		: 2551.657
cache size	: 46080 KB
```

## Memory Information
```
               total        used        free      shared  buff/cache   available
Mem:           125Gi       3.4Gi       122Gi        50Mi       202Mi       122Gi
Swap:             0B          0B          0B

Memory Details:
	Error Correction Type: Multi-bit ECC
	Size: 32 GB
	Type: DDR4
	Speed: 2400 MT/s
	Manufacturer: Hynix Semiconductor
	Serial Number: 916E6191
	Configured Memory Speed: 2400 MT/s
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Error Correction Type: Multi-bit ECC
	Size: 32 GB
	Type: DDR4
	Speed: 2400 MT/s
	Manufacturer: Hynix Semiconductor
	Serial Number: 91AFAE8C
	Configured Memory Speed: 2400 MT/s
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Error Correction Type: Multi-bit ECC
	Size: 32 GB
	Type: DDR4
	Speed: 2400 MT/s
	Manufacturer: Hynix Semiconductor
	Serial Number: 919E07C7
	Configured Memory Speed: 2400 MT/s
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Error Correction Type: Multi-bit ECC
	Size: 32 GB
	Type: DDR4
	Speed: 2400 MT/s
	Manufacturer: Hynix Semiconductor
	Serial Number: 91B12050
	Configured Memory Speed: 2400 MT/s
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Type: Unknown
	Type: Unknown
```

## Network Interfaces
```
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp8s0           UP             
enp9s0           DOWN           
vmbr0            UP             192.168.10.16/16 fe80::2f6:2cff:fe0a:73a9/64 

=== MAC Addresses ===
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 2: enp8s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master vmbr0 state UP mode DEFAULT group default qlen 1000
    link/ether 00:f6:2c:0a:73:a9 brd ff:ff:ff:ff:ff:ff 3: enp9s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 00:f6:2c:0a:73:aa brd ff:ff:ff:ff:ff:ff 4: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 00:f6:2c:0a:73:a9 brd ff:ff:ff:ff:ff:ff
```

### Network Interface Details
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp8s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master vmbr0 state UP group default qlen 1000
    link/ether 00:f6:2c:0a:73:a9 brd ff:ff:ff:ff:ff:ff
    altname enx00f62c0a73a9
3: enp9s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 00:f6:2c:0a:73:aa brd ff:ff:ff:ff:ff:ff
    altname enx00f62c0a73aa
4: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:f6:2c:0a:73:a9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.16/16 scope global vmbr0
       valid_lft forever preferred_lft forever
    inet6 fe80::2f6:2cff:fe0a:73a9/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
```

## Storage Devices
```
NAME          SIZE TYPE FSTYPE     MOUNTPOINT MODEL                  SERIAL
nvme1n1     476.9G disk                       Patriot M.2 P300 512GB P300PDCB250729004067
nvme3n1     476.9G disk                       Patriot M.2 P300 512GB P300PDCB250729004065
nvme2n1     476.9G disk                       Patriot M.2 P300 512GB P300PDCB250729004457
nvme4n1     476.9G disk                       Patriot M.2 P300 512GB P300PDCB250729008158
nvme0n1     476.9G disk                       YSO512GTLCW-E3C-2      511231018191001983
├─nvme0n1p1  1007K part                                              
├─nvme0n1p2     1G part vfat                                         
└─nvme0n1p3   475G part zfs_member                                   
```

### Disk Details (Unmounted/Unpartitioned)
```
nvme1n1     476.9G disk            
nvme3n1     476.9G disk            
nvme2n1     476.9G disk            
nvme4n1     476.9G disk            
nvme0n1     476.9G disk            
├─nvme0n1p1  1007K part            
├─nvme0n1p2     1G part vfat       
└─nvme0n1p3   475G part zfs_member 

=== All Block Devices ===
Disk /dev/nvme3n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: Patriot M.2 P300 512GB                  
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/nvme1n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: Patriot M.2 P300 512GB                  
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/nvme2n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: Patriot M.2 P300 512GB                  
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/nvme4n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: Patriot M.2 P300 512GB                  
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/nvme0n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: YSO512GTLCW-E3C-2                       
Sector size (logical/physical): 512 bytes / 512 bytes
```

### SMART Status
```
=== /dev/nvme1n1 ===
Model Number:                       Patriot M.2 P300 512GB
Serial Number:                      P300PDCB250729004067
Total NVM Capacity:                 512,110,190,592 [512 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          512,110,190,592 [512 GB]
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme3n1 ===
Model Number:                       Patriot M.2 P300 512GB
Serial Number:                      P300PDCB250729004065
Total NVM Capacity:                 512,110,190,592 [512 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          512,110,190,592 [512 GB]
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme2n1 ===
Model Number:                       Patriot M.2 P300 512GB
Serial Number:                      P300PDCB250729004457
Total NVM Capacity:                 512,110,190,592 [512 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          512,110,190,592 [512 GB]
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme4n1 ===
Model Number:                       Patriot M.2 P300 512GB
Serial Number:                      P300PDCB250729008158
Total NVM Capacity:                 512,110,190,592 [512 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          512,110,190,592 [512 GB]
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme0n1 ===
Model Number:                       YSO512GTLCW-E3C-2
Serial Number:                      511231018191001983
Total NVM Capacity:                 512,110,190,592 [512 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          512,110,190,592 [512 GB]
SMART overall-health self-assessment test result: PASSED

```

## PCI Devices
```
00:14.0 USB controller: Intel Corporation C610/X99 series chipset USB xHCI Host Controller (rev 05)
00:1a.0 USB controller: Intel Corporation C610/X99 series chipset USB Enhanced Host Controller #2 (rev 05)
00:1b.0 Audio device: Intel Corporation C610/X99 series chipset HD Audio Controller (rev 05)
00:1d.0 USB controller: Intel Corporation C610/X99 series chipset USB Enhanced Host Controller #1 (rev 05)
02:00.0 Non-Volatile memory controller: Phison Electronics Corporation PS5013-E13 PCIe3 NVMe Controller (DRAM-less) (rev 01)
03:00.0 Non-Volatile memory controller: MAXIO Technology (Hangzhou) Ltd. NVMe SSD Controller MAP1202 (DRAM-less) (rev 01)
04:00.0 Non-Volatile memory controller: MAXIO Technology (Hangzhou) Ltd. NVMe SSD Controller MAP1202 (DRAM-less) (rev 01)
05:00.0 Non-Volatile memory controller: MAXIO Technology (Hangzhou) Ltd. NVMe SSD Controller MAP1202 (DRAM-less) (rev 01)
08:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet Controller (rev 15)
09:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet Controller (rev 15)
0a:00.0 Non-Volatile memory controller: MAXIO Technology (Hangzhou) Ltd. NVMe SSD Controller MAP1202 (DRAM-less) (rev 01)
83:00.0 VGA compatible controller: Intel Corporation DG2 [Arc A770] (rev 08)
84:00.0 Audio device: Intel Corporation DG2 Audio Controller
87:00.0 VGA compatible controller: Intel Corporation DG2 [Arc A770] (rev 08)
88:00.0 Audio device: Intel Corporation DG2 Audio Controller
```

### Detailed PCI Info
```
08:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet Controller (rev 15)
	Subsystem: Realtek Semiconductor Co., Ltd. Device 0123
	Flags: bus master, fast devsel, latency 0, IRQ 16, NUMA node 0, IOMMU group 103
	I/O ports at 6000 [size=256]
	Memory at bfa04000 (64-bit, non-prefetchable) [size=4K]
	Memory at bfa00000 (64-bit, non-prefetchable) [size=16K]
--
09:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet Controller (rev 15)
	Subsystem: Realtek Semiconductor Co., Ltd. Device 0123
	Flags: bus master, fast devsel, latency 0, IRQ 18, NUMA node 0, IOMMU group 104
	I/O ports at 5000 [size=256]
	Memory at bf904000 (64-bit, non-prefetchable) [size=4K]
	Memory at bf900000 (64-bit, non-prefetchable) [size=16K]
```

## USB Devices
```
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 8087:800a Intel Corp. Hub
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 002: ID 8087:8002 Intel Corp. 8 channel internal hub
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```

## ZFS Pools (if any)
```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
rpool   472G  2.79G   469G        -         -     0%     0%  1.00x    ONLINE  -

  pool: rpool
 state: ONLINE
config:

	NAME                               STATE     READ WRITE CKSUM
	rpool                              ONLINE       0     0     0
	  nvme-eui.6479a784ba50082f-part3  ONLINE       0     0     0

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
ceph-fuse: 19.2.3-pve1
corosync: 3.1.9-pve2
criu: 4.1.1-1
frr-pythontools: 10.3.1-1+pve4
ifupdown2: 3.3.0-1+pmx11
intel-microcode: 3.20250812.1~deb13u1
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
local             dir     active       476670976             128       476670848    0.00%
local-zfs     zfspool     active       476671036              96       476670940    0.00%
```

### Proxmox Network Configuration
```
auto lo
iface lo inet loopback

iface enp8s0 inet manual

auto vmbr0
iface vmbr0 inet static
	address 192.168.10.16/16
	gateway 192.168.1.1
	bridge-ports enp8s0
	bridge-stp off
	bridge-fd 0

iface enp9s0 inet manual


source /etc/network/interfaces.d/*
```

## Hardware Sensors (if available)
```
lm-sensors not installed
```

## DMI/SMBIOS Information
```
=== System ===
	Manufacturer: INTEL
	Product Name: X99
	Serial Number: Default string
	UUID: 03000200-0400-0500-0006-000700080009

=== BIOS ===
	Vendor: American Megatrends Inc.
	Version: 5.11
	Release Date: 11/14/2024

=== Baseboard ===
	Manufacturer: INTEL
	Product Name: X99
	Serial Number: Default string
```

---
Report generated on 2025-11-30 16:03:35
