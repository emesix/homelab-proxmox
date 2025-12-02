# Hardware Report: pve-hx310-arr
Generated: 2025-11-30 16:03:28

## System Information
```
Hostname: pve-hx310-arr.internal
Kernel: 6.17.2-1-pve
OS: Debian GNU/Linux 13 (trixie)
Uptime: up 4 hours, 23 minutes
Architecture: x86_64
```

## CPU Information
```
Architecture:                            x86_64
CPU(s):                                  4
On-line CPU(s) list:                     0-3
Vendor ID:                               GenuineIntel
Model name:                              Intel(R) Pentium(R) J6426 @ 2.00GHz
Thread(s) per core:                      1
Core(s) per socket:                      4
Socket(s):                               1
CPU(s) scaling MHz:                      90%
CPU max MHz:                             3000.0000
CPU min MHz:                             800.0000
NUMA node0 CPU(s):                       0-3
```

### Detailed CPU Info
```
processor	: 0
model name	: Intel(R) Pentium(R) J6426 @ 2.00GHz
cpu MHz		: 2703.562
cache size	: 4096 KB
processor	: 1
model name	: Intel(R) Pentium(R) J6426 @ 2.00GHz
cpu MHz		: 2700.607
cache size	: 4096 KB
processor	: 2
model name	: Intel(R) Pentium(R) J6426 @ 2.00GHz
cpu MHz		: 2700.000
cache size	: 4096 KB
processor	: 3
model name	: Intel(R) Pentium(R) J6426 @ 2.00GHz
cpu MHz		: 2700.000
cache size	: 4096 KB
```

## Memory Information
```
               total        used        free      shared  buff/cache   available
Mem:            31Gi       2.3Gi        29Gi        49Mi       244Mi        28Gi
Swap:             0B          0B          0B

Memory Details:
	Error Correction Type: None
	Size: 16 GB
	Type: DDR4
	Speed: 3200 MT/s
	Manufacturer: Kingston
	Serial Number: 3A497265
	Configured Memory Speed: 3200 MT/s
	Size: 16 GB
	Type: DDR4
	Speed: 3200 MT/s
	Manufacturer: Kingston
	Serial Number: 384971D8
	Configured Memory Speed: 3200 MT/s
```

## Network Interfaces
```
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp0s29f1        UP             
enp0s29f2        DOWN           
vmbr0            UP             192.168.10.13/16 fe80::868b:cdff:fe4d:b64f/64 

=== MAC Addresses ===
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 2: enp0s29f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vmbr0 state UP mode DEFAULT group default qlen 1000
    link/ether 84:8b:cd:4d:b6:4f brd ff:ff:ff:ff:ff:ff 3: enp0s29f2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 84:8b:cd:4d:bc:8f brd ff:ff:ff:ff:ff:ff 4: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 84:8b:cd:4d:b6:4f brd ff:ff:ff:ff:ff:ff
```

### Network Interface Details
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s29f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vmbr0 state UP group default qlen 1000
    link/ether 84:8b:cd:4d:b6:4f brd ff:ff:ff:ff:ff:ff
    altname enx848bcd4db64f
3: enp0s29f2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 84:8b:cd:4d:bc:8f brd ff:ff:ff:ff:ff:ff
    altname enx848bcd4dbc8f
4: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 84:8b:cd:4d:b6:4f brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.13/16 scope global vmbr0
       valid_lft forever preferred_lft forever
    inet6 fe80::868b:cdff:fe4d:b64f/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
```

## Storage Devices
```
NAME          SIZE TYPE FSTYPE     MOUNTPOINT MODEL        SERIAL
nvme0n1     931.5G disk                       CT1000P3SSD8 24494CB8AB2B
├─nvme0n1p1  1007K part                                    
├─nvme0n1p2     1G part vfat                               
└─nvme0n1p3   930G part zfs_member                         
```

### Disk Details (Unmounted/Unpartitioned)
```
nvme0n1     931.5G disk            
├─nvme0n1p1  1007K part            
├─nvme0n1p2     1G part vfat       
└─nvme0n1p3   930G part zfs_member 

=== All Block Devices ===
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: CT1000P3SSD8                            
Sector size (logical/physical): 512 bytes / 512 bytes
```

### SMART Status
```
=== /dev/nvme0n1 ===
Model Number:                       CT1000P3SSD8
Serial Number:                      24494CB8AB2B
Namespace 1 Size/Capacity:          1,000,204,886,016 [1.00 TB]
SMART overall-health self-assessment test result: PASSED

```

## PCI Devices
```
00:02.0 VGA compatible controller: Intel Corporation Elkhart Lake [UHD Graphics Gen11 32EU] (rev 01)
00:14.0 USB controller: Intel Corporation Elkhart Lake USB 3.10 XHCI (rev 11)
00:17.0 SATA controller: Intel Corporation Elkhart Lake SATA AHCI (rev 11)
00:1d.1 Ethernet controller: Intel Corporation Device 4ba1 (rev 11)
00:1d.2 Ethernet controller: Intel Corporation Device 4bb1 (rev 11)
00:1f.3 Audio device: Intel Corporation Elkhart Lake High Density Audio bus interface (rev 11)
01:00.0 Non-Volatile memory controller: Micron Technology Inc 2550 NVMe SSD (DRAM-less) (rev 01)
```

### Detailed PCI Info
```
00:1d.1 Ethernet controller: Intel Corporation Device 4ba1 (rev 11) (prog-if 18)
	Subsystem: Intel Corporation Device 7270
	Flags: bus master, fast devsel, latency 0, IRQ 134, IOMMU group 11
	Memory at 6fc00000 (64-bit, non-prefetchable) [size=256K]
	Capabilities: [80] Power Management version 3
	Capabilities: [90] Vendor Specific Information: Len=14 <?>
--
00:1d.2 Ethernet controller: Intel Corporation Device 4bb1 (rev 11) (prog-if 19)
	Subsystem: Intel Corporation Device 7270
	Flags: bus master, fast devsel, latency 0, IRQ 171, IOMMU group 11
	Memory at 6fc40000 (64-bit, non-prefetchable) [size=256K]
	Capabilities: [80] Power Management version 3
	Capabilities: [90] Vendor Specific Information: Len=14 <?>
```

## USB Devices
```
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```

## ZFS Pools (if any)
```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
rpool   928G  2.94G   925G        -         -     0%     0%  1.00x    ONLINE  -

  pool: rpool
 state: ONLINE
config:

	NAME                                    STATE     READ WRITE CKSUM
	rpool                                   ONLINE       0     0     0
	  nvme-CT1000P3SSD8_24494CB8AB2B-part3  ONLINE       0     0     0

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
local             dir     active       939847296             128       939847168    0.00%
local-zfs     zfspool     active       939847384              96       939847288    0.00%
```

### Proxmox Network Configuration
```
auto lo
iface lo inet loopback

iface enp0s29f1 inet manual

auto vmbr0
iface vmbr0 inet static
	address 192.168.10.13/16
	gateway 192.168.1.1
	bridge-ports enp0s29f1
	bridge-stp off
	bridge-fd 0

iface enp0s29f2 inet manual


source /etc/network/interfaces.d/*
```

## Hardware Sensors (if available)
```
lm-sensors not installed
```

## DMI/SMBIOS Information
```
=== System ===
	Manufacturer: OnLogic
	Product Name: Helix3X0
	Serial Number: E290624
	UUID: f523eb99-2d29-4e91-af0d-2bfc827c94dc

=== BIOS ===
	Vendor: INSYDE Corp.
	Version: Z01-0003A073
	Release Date: 2023-03-01

=== Baseboard ===
	Manufacturer: OnLogic
	Product Name: HX3x0
	Serial Number: L238001844
```

---
Report generated on 2025-11-30 16:03:28
