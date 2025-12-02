# Hardware Report: pve-qotom01
Generated: 2025-11-30 16:03:11

## System Information
```
Hostname: pve-qotom01.internal
Kernel: 6.17.2-1-pve
OS: Debian GNU/Linux 13 (trixie)
Uptime: up 4 hours, 29 minutes
Architecture: x86_64
```

## CPU Information
```
Architecture:                            x86_64
CPU(s):                                  8
On-line CPU(s) list:                     0-7
Vendor ID:                               GenuineIntel
Model name:                              Intel(R) Atom(TM) CPU C3758R @ 2.40GHz
Thread(s) per core:                      1
Core(s) per socket:                      8
Socket(s):                               1
CPU(s) scaling MHz:                      100%
CPU max MHz:                             2400.0000
CPU min MHz:                             800.0000
NUMA node0 CPU(s):                       0-7
```

### Detailed CPU Info
```
processor	: 0
model name	: Intel(R) Atom(TM) CPU C3758R @ 2.40GHz
cpu MHz		: 2400.000
cache size	: 2048 KB
processor	: 1
model name	: Intel(R) Atom(TM) CPU C3758R @ 2.40GHz
cpu MHz		: 2400.000
cache size	: 2048 KB
processor	: 2
model name	: Intel(R) Atom(TM) CPU C3758R @ 2.40GHz
cpu MHz		: 2399.976
cache size	: 2048 KB
processor	: 3
model name	: Intel(R) Atom(TM) CPU C3758R @ 2.40GHz
cpu MHz		: 2400.000
cache size	: 2048 KB
processor	: 4
model name	: Intel(R) Atom(TM) CPU C3758R @ 2.40GHz
cpu MHz		: 2400.000
cache size	: 2048 KB
```

## Memory Information
```
               total        used        free      shared  buff/cache   available
Mem:            62Gi       2.1Gi        61Gi        58Mi       186Mi        60Gi
Swap:             0B          0B          0B

Memory Details:
	Error Correction Type: None
	Size: 32 GB
	Type: DDR4
	Speed: 3200 MT/s
	Manufacturer: Micron Technology
	Serial Number: EB559756
	Configured Memory Speed: 2400 MT/s
	Type: Unknown
	Size: 32 GB
	Type: DDR4
	Speed: 3200 MT/s
	Manufacturer: Micron Technology
	Serial Number: EB559712
	Configured Memory Speed: 2400 MT/s
	Type: Unknown
```

## Network Interfaces
```
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp4s0           DOWN           
enp5s0           DOWN           
enp6s0           DOWN           
enp7s0           DOWN           
enp8s0           UP             
eno1             DOWN           
eno2             DOWN           
eno3             DOWN           
eno4             DOWN           
vmbr0            UP             192.168.10.11/16 fe80::227c:14ff:fef4:7875/64 

=== MAC Addresses ===
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 2: enp4s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:71 brd ff:ff:ff:ff:ff:ff 3: enp5s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:72 brd ff:ff:ff:ff:ff:ff 4: enp6s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:73 brd ff:ff:ff:ff:ff:ff 5: enp7s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:74 brd ff:ff:ff:ff:ff:ff 6: enp8s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vmbr0 state UP mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:75 brd ff:ff:ff:ff:ff:ff 7: eno1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:76 brd ff:ff:ff:ff:ff:ff 8: eno2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:77 brd ff:ff:ff:ff:ff:ff 9: eno3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:78 brd ff:ff:ff:ff:ff:ff 10: eno4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:79 brd ff:ff:ff:ff:ff:ff 11: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 20:7c:14:f4:78:75 brd ff:ff:ff:ff:ff:ff
```

### Network Interface Details
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp4s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 20:7c:14:f4:78:71 brd ff:ff:ff:ff:ff:ff
    altname enx207c14f47871
3: enp5s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 20:7c:14:f4:78:72 brd ff:ff:ff:ff:ff:ff
    altname enx207c14f47872
4: enp6s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 20:7c:14:f4:78:73 brd ff:ff:ff:ff:ff:ff
    altname enx207c14f47873
5: enp7s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 20:7c:14:f4:78:74 brd ff:ff:ff:ff:ff:ff
    altname enx207c14f47874
6: enp8s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vmbr0 state UP group default qlen 1000
    link/ether 20:7c:14:f4:78:75 brd ff:ff:ff:ff:ff:ff
    altname enx207c14f47875
7: eno1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 20:7c:14:f4:78:76 brd ff:ff:ff:ff:ff:ff
    altname enp11s0f0
    altname enx207c14f47876
8: eno2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 20:7c:14:f4:78:77 brd ff:ff:ff:ff:ff:ff
    altname enp11s0f1
    altname enx207c14f47877
9: eno3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 20:7c:14:f4:78:78 brd ff:ff:ff:ff:ff:ff
    altname enp12s0f0
    altname enx207c14f47878
10: eno4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 20:7c:14:f4:78:79 brd ff:ff:ff:ff:ff:ff
    altname enp12s0f1
    altname enx207c14f47879
11: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 20:7c:14:f4:78:75 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.11/16 scope global vmbr0
       valid_lft forever preferred_lft forever
    inet6 fe80::227c:14ff:fef4:7875/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
```

## Storage Devices
```
NAME          SIZE TYPE FSTYPE     MOUNTPOINT MODEL              SERIAL
sda         931.5G disk                       CT1000MX500SSD1    2320E6D81EF8
├─sda1      931.5G part zfs_member                               
└─sda9          8M part                                          
sdb         931.5G disk                       CT1000MX500SSD1    2317E6CE1704
├─sdb1      931.5G part zfs_member                               
└─sdb9          8M part                                          
nvme0n1     465.8G disk                       WD Red SN700 500GB 25035L804494
├─nvme0n1p1  1007K part                                          
├─nvme0n1p2     1G part vfat                                     
└─nvme0n1p3   464G part zfs_member                               
nvme1n1     465.8G disk                       WD Red SN700 500GB 25035L801804
├─nvme1n1p1  1007K part                                          
├─nvme1n1p2     1G part vfat                                     
└─nvme1n1p3   464G part zfs_member                               
```

### Disk Details (Unmounted/Unpartitioned)
```
sda         931.5G disk            
├─sda1      931.5G part zfs_member 
└─sda9          8M part            
sdb         931.5G disk            
├─sdb1      931.5G part zfs_member 
└─sdb9          8M part            
nvme0n1     465.8G disk            
├─nvme0n1p1  1007K part            
├─nvme0n1p2     1G part vfat       
└─nvme0n1p3   464G part zfs_member 
nvme1n1     465.8G disk            
├─nvme1n1p1  1007K part            
├─nvme1n1p2     1G part vfat       
└─nvme1n1p3   464G part zfs_member 

=== All Block Devices ===
Disk /dev/nvme0n1: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: WD Red SN700 500GB                      
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/nvme1n1: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: WD Red SN700 500GB                      
Sector size (logical/physical): 512 bytes / 512 bytes
Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: CT1000MX500SSD1 
Sector size (logical/physical): 512 bytes / 4096 bytes
Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: CT1000MX500SSD1 
Sector size (logical/physical): 512 bytes / 4096 bytes
```

### SMART Status
```
=== /dev/sda ===
Model Family:     Crucial/Micron Client SSDs
Device Model:     CT1000MX500SSD1
Serial Number:    2320E6D81EF8
User Capacity:    1,000,204,886,016 bytes [1.00 TB]
SMART support is: Available - device has SMART capability.
SMART support is: Enabled
SMART overall-health self-assessment test result: PASSED

=== /dev/sdb ===
Model Family:     Crucial/Micron Client SSDs
Device Model:     CT1000MX500SSD1
Serial Number:    2317E6CE1704
User Capacity:    1,000,204,886,016 bytes [1.00 TB]
SMART support is: Available - device has SMART capability.
SMART support is: Enabled
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme0n1 ===
Model Number:                       WD Red SN700 500GB
Serial Number:                      25035L804494
Total NVM Capacity:                 500,107,862,016 [500 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          500,107,862,016 [500 GB]
SMART overall-health self-assessment test result: PASSED

=== /dev/nvme1n1 ===
Model Number:                       WD Red SN700 500GB
Serial Number:                      25035L801804
Total NVM Capacity:                 500,107,862,016 [500 GB]
Unallocated NVM Capacity:           0
Namespace 1 Size/Capacity:          500,107,862,016 [500 GB]
SMART overall-health self-assessment test result: PASSED

```

## PCI Devices
```
00:13.0 SATA controller: Intel Corporation Atom Processor C3000 Series SATA Controller 0 (rev 11)
00:14.0 SATA controller: Intel Corporation Atom Processor C3000 Series SATA Controller 1 (rev 11)
00:15.0 USB controller: Intel Corporation Atom Processor C3000 Series USB 3.0 xHCI Controller (rev 11)
02:00.0 Non-Volatile memory controller: Sandisk Corp SanDisk Extreme Pro / WD Black SN750 / PC SN730 / Red SN700 NVMe SSD
03:00.0 Non-Volatile memory controller: Sandisk Corp SanDisk Extreme Pro / WD Black SN750 / PC SN730 / Red SN700 NVMe SSD
04:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
05:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
06:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
07:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
08:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
0a:00.0 VGA compatible controller: ASPEED Technology, Inc. ASPEED Graphics Family (rev 30)
0b:00.0 Ethernet controller: Intel Corporation Ethernet Connection X553 10 GbE SFP+ (rev 11)
0b:00.1 Ethernet controller: Intel Corporation Ethernet Connection X553 10 GbE SFP+ (rev 11)
0c:00.0 Ethernet controller: Intel Corporation Ethernet Connection X553 10 GbE SFP+ (rev 11)
0c:00.1 Ethernet controller: Intel Corporation Ethernet Connection X553 10 GbE SFP+ (rev 11)
```

### Detailed PCI Info
```
04:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
	Subsystem: Intel Corporation Device 0000
	Flags: bus master, fast devsel, latency 0, IRQ 18, IOMMU group 24
	Memory at dee00000 (32-bit, non-prefetchable) [size=1M]
	Memory at def00000 (32-bit, non-prefetchable) [size=16K]
	Expansion ROM at ded00000 [disabled] [size=1M]
--
05:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
	Subsystem: Intel Corporation Device 0000
	Flags: bus master, fast devsel, latency 0, IRQ 19, IOMMU group 25
	Memory at deb00000 (32-bit, non-prefetchable) [size=1M]
	Memory at dec00000 (32-bit, non-prefetchable) [size=16K]
	Expansion ROM at dea00000 [disabled] [size=1M]
--
06:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
	Subsystem: Intel Corporation Device 0000
	Flags: bus master, fast devsel, latency 0, IRQ 20, IOMMU group 26
	Memory at de800000 (32-bit, non-prefetchable) [size=1M]
	Memory at de900000 (32-bit, non-prefetchable) [size=16K]
	Expansion ROM at de700000 [disabled] [size=1M]
--
07:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
	Subsystem: Intel Corporation Device 0000
	Flags: bus master, fast devsel, latency 0, IRQ 21, IOMMU group 27
	Memory at de500000 (32-bit, non-prefetchable) [size=1M]
	Memory at de600000 (32-bit, non-prefetchable) [size=16K]
	Expansion ROM at de400000 [disabled] [size=1M]
--
08:00.0 Ethernet controller: Intel Corporation Ethernet Controller I226-V (rev 04)
	Subsystem: Intel Corporation Device 0000
	Flags: bus master, fast devsel, latency 0, IRQ 22, IOMMU group 28
	Memory at de200000 (32-bit, non-prefetchable) [size=1M]
	Memory at de300000 (32-bit, non-prefetchable) [size=16K]
	Expansion ROM at de100000 [disabled] [size=1M]
--
0b:00.0 Ethernet controller: Intel Corporation Ethernet Connection X553 10 GbE SFP+ (rev 11)
	DeviceName: Onboard LAN
	Subsystem: Intel Corporation Device 0000
	Flags: bus master, fast devsel, latency 0, IRQ 16, IOMMU group 30
	Memory at dcc00000 (64-bit, prefetchable) [size=2M]
```

## USB Devices
```
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 05e3:0608 Genesys Logic, Inc. Hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```

## ZFS Pools (if any)
```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
rpool   460G  2.79G   457G        -         -     0%     0%  1.00x    ONLINE  -

  pool: rpool
 state: ONLINE
config:

	NAME                                                 STATE     READ WRITE CKSUM
	rpool                                                ONLINE       0     0     0
	  mirror-0                                           ONLINE       0     0     0
	    nvme-eui.e8238fa6bf530001001b448b4d53b464-part3  ONLINE       0     0     0
	    nvme-eui.e8238fa6bf530001001b448b4d534140-part3  ONLINE       0     0     0

errors: No known data errors
```

## LVM Information (if any)
```


```

## Proxmox VE Information
```
proxmox-ve: 9.1.0 (running kernel: 6.17.2-1-pve)
pve-manager: 9.1.1 (running version: 9.1.1/42db4a6cf33dac83)
proxmox-kernel-helper: 9.0.4
proxmox-kernel-6.17.2-1-pve-signed: 6.17.2-1
proxmox-kernel-6.17: 6.17.2-1
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
local             dir     active       464475264             128       464475136    0.00%
local-zfs     zfspool     active       464475292              96       464475196    0.00%
```

### Proxmox Network Configuration
```
auto lo
iface lo inet loopback

iface enp8s0 inet manual

auto vmbr0
iface vmbr0 inet static
	address 192.168.10.11/16
	gateway 192.168.1.1
	bridge-ports enp8s0
	bridge-stp off
	bridge-fd 0

iface eno4 inet manual

iface enp4s0 inet manual

iface enp5s0 inet manual

iface enp6s0 inet manual

iface enp7s0 inet manual

iface eno1 inet manual

iface eno2 inet manual

iface eno3 inet manual


source /etc/network/interfaces.d/*
```

## Hardware Sensors (if available)
```
lm-sensors not installed
```

## DMI/SMBIOS Information
```
=== System ===
	Manufacturer: Default string
	Product Name: QDNV01
	Serial Number: Default string
	UUID: 03000200-0400-0500-0006-000700080009

=== BIOS ===
	Vendor: American Megatrends Inc.
	Version: 5.13
	Release Date: 02/21/2024

=== Baseboard ===
	Manufacturer: Default string
	Product Name: QDNV01
	Serial Number: Default string
```

---
Report generated on 2025-11-30 16:03:11
