# Hardware Report: pve-8845hs
Generated: 2025-11-30 16:03:32

## System Information
```
Hostname: pve-8845hs.internal
Kernel: 6.17.2-2-pve
OS: Debian GNU/Linux 13 (trixie)
Uptime: up 8 minutes
Architecture: x86_64
```

## CPU Information
```
Architecture:                            x86_64
CPU(s):                                  16
On-line CPU(s) list:                     0-15
Vendor ID:                               AuthenticAMD
Model name:                              AMD Ryzen 7 PRO 8845HS w/ Radeon 780M Graphics
Thread(s) per core:                      2
Core(s) per socket:                      8
Socket(s):                               1
CPU(s) scaling MHz:                      47%
CPU max MHz:                             5137.9038
CPU min MHz:                             419.4210
NUMA node0 CPU(s):                       0-15
```

### Detailed CPU Info
```
processor	: 0
model name	: AMD Ryzen 7 PRO 8845HS w/ Radeon 780M Graphics
cpu MHz		: 3029.576
cache size	: 1024 KB
processor	: 1
model name	: AMD Ryzen 7 PRO 8845HS w/ Radeon 780M Graphics
cpu MHz		: 1100.980
cache size	: 1024 KB
processor	: 2
model name	: AMD Ryzen 7 PRO 8845HS w/ Radeon 780M Graphics
cpu MHz		: 3118.651
cache size	: 1024 KB
processor	: 3
model name	: AMD Ryzen 7 PRO 8845HS w/ Radeon 780M Graphics
cpu MHz		: 3360.816
cache size	: 1024 KB
processor	: 4
model name	: AMD Ryzen 7 PRO 8845HS w/ Radeon 780M Graphics
cpu MHz		: 1100.980
cache size	: 1024 KB
```

## Memory Information
```
               total        used        free      shared  buff/cache   available
Mem:            60Gi       2.4Gi        58Gi        36Mi       173Mi        58Gi
Swap:             0B          0B          0B

Memory Details:
	Error Correction Type: None
	Size: 32 GB
	Type: DDR5
	Speed: 4800 MT/s
	Manufacturer: CASE_STRING_4
	Serial Number: EB5457C3
	Configured Memory Speed: 4800 MT/s
	Module Manufacturer ID: Bank 1, Hex 0x2C
	Memory Subsystem Controller Manufacturer ID: Unknown
	Non-Volatile Size: None
	Volatile Size: 32 GB
	Cache Size: None
	Logical Size: None
	Size: 32 GB
	Type: DDR5
	Speed: 4800 MT/s
	Manufacturer: CASE_STRING_4
	Serial Number: EB54579E
	Configured Memory Speed: 4800 MT/s
	Module Manufacturer ID: Bank 1, Hex 0x2C
	Memory Subsystem Controller Manufacturer ID: Unknown
	Non-Volatile Size: None
	Volatile Size: 32 GB
	Cache Size: None
	Logical Size: None
```

## Network Interfaces
```
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp4s0           UP             
enp5s0           DOWN           
vmbr0            UP             192.168.10.15/16 fe80::aab8:e0ff:fe0a:2fe8/64 

=== MAC Addresses ===
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 2: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vmbr0 state UP mode DEFAULT group default qlen 1000
    link/ether a8:b8:e0:0a:2f:e8 brd ff:ff:ff:ff:ff:ff 3: enp5s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether a8:b8:e0:0a:2f:e9 brd ff:ff:ff:ff:ff:ff 4: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether a8:b8:e0:0a:2f:e8 brd ff:ff:ff:ff:ff:ff
```

### Network Interface Details
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vmbr0 state UP group default qlen 1000
    link/ether a8:b8:e0:0a:2f:e8 brd ff:ff:ff:ff:ff:ff
    altname enxa8b8e00a2fe8
3: enp5s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether a8:b8:e0:0a:2f:e9 brd ff:ff:ff:ff:ff:ff
    altname enxa8b8e00a2fe9
4: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether a8:b8:e0:0a:2f:e8 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.15/16 scope global vmbr0
       valid_lft forever preferred_lft forever
    inet6 fe80::aab8:e0ff:fe0a:2fe8/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
```

## Storage Devices
```
NAME          SIZE TYPE FSTYPE     MOUNTPOINT MODEL        SERIAL
nvme1n1     465.8G disk                       CT500P5PSSD8 22493D0CE416
├─nvme1n1p1  1007K part                                    
├─nvme1n1p2     1G part vfat                               
└─nvme1n1p3   464G part zfs_member                         
nvme0n1     465.8G disk                       CT500P5PSSD8 23123F86BF7B
├─nvme0n1p1  1007K part                                    
├─nvme0n1p2     1G part vfat                               
└─nvme0n1p3   464G part zfs_member                         
```

### Disk Details (Unmounted/Unpartitioned)
```
nvme1n1     465.8G disk            
├─nvme1n1p1  1007K part            
├─nvme1n1p2     1G part vfat       
└─nvme1n1p3   464G part zfs_member 
nvme0n1     465.8G disk            
├─nvme0n1p1  1007K part            
├─nvme0n1p2     1G part vfat       
└─nvme0n1p3   464G part zfs_member 

=== All Block Devices ===
Disk /dev/nvme1n1: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: CT500P5PSSD8                            
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/nvme0n1: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: CT500P5PSSD8                            
Sector size (logical/physical): 512 bytes / 512 bytes
```

### SMART Status
```
=== /dev/nvme1n1 ===
Model Number:                       CT500P5PSSD8
Serial Number:                      22493D0CE416
Total NVM Capacity:                 500,107,862,016 [500 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          500,107,862,016 [500 GB]
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme0n1 ===
Model Number:                       CT500P5PSSD8
Serial Number:                      23123F86BF7B
Total NVM Capacity:                 500,107,862,016 [500 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          500,107,862,016 [500 GB]
SMART overall-health self-assessment test result: PASSED

```

## PCI Devices
```
00:03.1 PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 19h USB4/Thunderbolt PCIe tunnel
00:04.1 PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 19h USB4/Thunderbolt PCIe tunnel
01:00.0 Non-Volatile memory controller: Micron/Crucial Technology P5 Plus NVMe PCIe SSD
02:00.0 SATA controller: ASMedia Technology Inc. ASM1164 Serial ATA AHCI Controller (rev 02)
03:00.0 SATA controller: ASMedia Technology Inc. ASM1164 Serial ATA AHCI Controller (rev 02)
04:00.0 Ethernet controller: Aquantia Corp. AQtion AQC113 NBase-T/IEEE 802.3an Ethernet Controller [Antigua 10G] (rev 03)
05:00.0 Ethernet controller: Aquantia Corp. AQtion AQC113 NBase-T/IEEE 802.3an Ethernet Controller [Antigua 10G] (rev 03)
06:00.0 Non-Volatile memory controller: Micron/Crucial Technology P5 Plus NVMe PCIe SSD
c7:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Phoenix3 (rev d5)
c7:00.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Radeon High Definition Audio Controller [Rembrandt/Strix]
c7:00.3 USB controller: Advanced Micro Devices, Inc. [AMD] Device 15b9
c7:00.4 USB controller: Advanced Micro Devices, Inc. [AMD] Device 15ba
c7:00.5 Multimedia controller: Advanced Micro Devices, Inc. [AMD] Audio Coprocessor (rev 63)
c7:00.6 Audio device: Advanced Micro Devices, Inc. [AMD] Family 17h/19h/1ah HD Audio Controller
c9:00.3 USB controller: Advanced Micro Devices, Inc. [AMD] Device 15c0
c9:00.4 USB controller: Advanced Micro Devices, Inc. [AMD] Device 15c1
c9:00.5 USB controller: Advanced Micro Devices, Inc. [AMD] Pink Sardine USB4/Thunderbolt NHI controller #1
c9:00.6 USB controller: Advanced Micro Devices, Inc. [AMD] Pink Sardine USB4/Thunderbolt NHI controller #2
```

### Detailed PCI Info
```
04:00.0 Ethernet controller: Aquantia Corp. AQtion AQC113 NBase-T/IEEE 802.3an Ethernet Controller [Antigua 10G] (rev 03)
	Subsystem: Aquantia Corp. Device 0001
	Flags: bus master, fast devsel, latency 0, IRQ 73, IOMMU group 19
	Memory at dcc00000 (64-bit, non-prefetchable) [size=512K]
	Memory at dcca0000 (64-bit, non-prefetchable) [size=4K]
	Memory at dc800000 (64-bit, non-prefetchable) [size=4M]
--
05:00.0 Ethernet controller: Aquantia Corp. AQtion AQC113 NBase-T/IEEE 802.3an Ethernet Controller [Antigua 10G] (rev 03)
	Subsystem: Aquantia Corp. Device 0001
	Flags: bus master, fast devsel, latency 0, IRQ 73, IOMMU group 20
	Memory at dc400000 (64-bit, non-prefetchable) [size=512K]
	Memory at dc4a0000 (64-bit, non-prefetchable) [size=4K]
	Memory at dc000000 (64-bit, non-prefetchable) [size=4M]
```

## USB Devices
```
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 174c:2074 ASMedia Technology Inc. ASM1074 High-Speed hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 002 Device 002: ID 174c:3074 ASMedia Technology Inc. ASM1074 SuperSpeed hub
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 005 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 006 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 007 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 008 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```

## ZFS Pools (if any)
```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
rpool   920G  2.73G   917G        -         -     0%     0%  1.00x    ONLINE  -

  pool: rpool
 state: ONLINE
config:

	NAME                                    STATE     READ WRITE CKSUM
	rpool                                   ONLINE       0     0     0
	  nvme-CT500P5PSSD8_22493D0CE416-part3  ONLINE       0     0     0
	  nvme-CT500P5PSSD8_23123F86BF7B-part3  ONLINE       0     0     0

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
local             dir     active       931939840             128       931939712    0.00%
local-zfs     zfspool     active       931939892              96       931939796    0.00%
```

### Proxmox Network Configuration
```
auto lo
iface lo inet loopback

iface enp4s0 inet manual

auto vmbr0
iface vmbr0 inet static
	address 192.168.10.15/16
	gateway 192.168.1.1
	bridge-ports enp4s0
	bridge-stp off
	bridge-fd 0

iface enp5s0 inet manual


source /etc/network/interfaces.d/*
```

## Hardware Sensors (if available)
```
lm-sensors not installed
```

## DMI/SMBIOS Information
```
=== System ===
	Manufacturer:  
	Product Name: AMD-FP7-NAS
	Serial Number: Default string
	UUID: 03000200-0400-0500-0006-000700080009

=== BIOS ===
	Vendor: American Megatrends International, LLC.
	Version: V1.0
	Release Date: 06/27/2025

=== Baseboard ===
	Manufacturer:  
	Product Name:  
	Serial Number: E73S0600850080
```

---
Report generated on 2025-11-30 16:03:32
