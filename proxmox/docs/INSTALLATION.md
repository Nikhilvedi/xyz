# Proxmox VE Installation Guide

This guide walks through setting up Proxmox VE on your home server from scratch.

## Prerequisites

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 64-bit with VT-x/AMD-V | Intel i5/Ryzen 5 or better |
| RAM | 4GB | 16GB+ (more for many VMs) |
| Storage | 32GB (OS) | 256GB SSD (OS) + additional for VMs |
| Network | 1 Gigabit port | 2+ Gigabit ports |

### What You'll Need

- USB flash drive (8GB+) for installation
- Keyboard and monitor (for initial setup)
- Ethernet cable
- Proxmox VE ISO image

## Step 1: Download Proxmox VE

1. Visit: https://www.proxmox.com/en/downloads
2. Download the latest Proxmox VE ISO Installer
3. Verify the checksum (optional but recommended)

## Step 2: Create Bootable USB

### On Linux/macOS:
```bash
# Find your USB device
lsblk

# Write ISO to USB (replace /dev/sdX with your device)
sudo dd bs=4M if=proxmox-ve_*.iso of=/dev/sdX conv=fdatasync status=progress
```

### On Windows:
Use [Rufus](https://rufus.ie/) or [Etcher](https://www.balena.io/etcher/)

## Step 3: Install Proxmox VE

1. Boot from USB (adjust BIOS/UEFI boot order)
2. Select "Install Proxmox VE"
3. Accept the EULA
4. Select target disk:
   - Choose SSD for best performance
   - Consider ZFS RAID for redundancy (if multiple drives)
5. Configure locale and timezone
6. Set admin password and email
7. Configure network:
   - Hostname: `proxmox.local` (or your choice)
   - IP Address: Static IP recommended (e.g., `192.168.1.10`)
   - Gateway: Your router IP
   - DNS: Your router or preferred DNS server

8. Review and install

## Step 4: Post-Installation Setup

### Access Web Interface

Open browser and navigate to:
```
https://192.168.1.10:8006
```
(Replace with your Proxmox IP)

Login with:
- Username: `root`
- Password: (what you set during install)
- Realm: `Linux PAM standard authentication`

### Remove Subscription Notice (Optional)

Edit the JavaScript file to remove the popup:
```bash
# SSH into Proxmox
ssh root@192.168.1.10

# Edit the file
sed -Ei.bak "s/NotFound/Active/g; s/notfound/active/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

# Restart pveproxy
systemctl restart pveproxy
```

### Add No-Subscription Repository

```bash
# Disable enterprise repository (if not subscribed)
echo "# Enterprise repository disabled" > /etc/apt/sources.list.d/pve-enterprise.list

# Add no-subscription repository
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

# Update packages
apt update && apt dist-upgrade -y
```

### Install Useful Tools

```bash
apt install -y \
    vim \
    htop \
    iotop \
    net-tools \
    curl \
    wget \
    git \
    tmux \
    sudo
```

## Step 5: Configure Storage

### View Current Storage
```bash
pvesm status
```

### Add NFS Storage (if you have a NAS)
1. Web UI → Datacenter → Storage → Add → NFS
2. Configure:
   - ID: `nas-storage`
   - Server: NAS IP address
   - Export: NFS share path
   - Content: Select what to store

### Create ZFS Pool (if you have multiple drives)
```bash
# List available disks
lsblk

# Create mirror (RAID1)
zpool create -f tank mirror /dev/sdb /dev/sdc

# Add to Proxmox
pvesm add zfspool tank --pool tank --content images,rootdir
```

## Step 6: Network Configuration

### View Current Network
```bash
cat /etc/network/interfaces
```

### Create Additional Bridge (for VM network)
Add to `/etc/network/interfaces`:
```
auto vmbr1
iface vmbr1 inet static
    address 10.0.0.1/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
```

Apply changes:
```bash
ifreload -a
```

## Step 7: Download VM/Container Templates

### Container Templates
1. Web UI → Local Storage → CT Templates → Templates
2. Download commonly used templates:
   - Debian 12
   - Ubuntu 22.04
   - Alpine Linux

### ISO Images
1. Upload your own ISOs or download from URLs
2. Web UI → Local Storage → ISO Images → Upload/Download from URL

## Step 8: Clone This Repository

```bash
cd /root
git clone https://github.com/Nikhilvedi/xyz.git
cd xyz/proxmox

# Make scripts executable
chmod +x scripts/*.sh

# Configure git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Step 9: Set Up Automated Backups

```bash
# Run initial backup
./scripts/backup-configs.sh

# Set up scheduled backups
./scripts/setup-cron.sh
```

## Security Hardening

### 1. Enable Firewall
```bash
# Enable PVE firewall
pve-firewall enable
```

### 2. Create Non-Root User
```bash
# Create user in PAM
adduser admin
usermod -aG sudo admin

# Create in Proxmox
pveum user add admin@pam
pveum aclmod / -user admin@pam -role Administrator
```

### 3. SSH Hardening
Edit `/etc/ssh/sshd_config`:
```
PermitRootLogin no
PasswordAuthentication no
```

Add your SSH key first:
```bash
mkdir -p /home/admin/.ssh
echo "your-public-key" >> /home/admin/.ssh/authorized_keys
chmod 700 /home/admin/.ssh
chmod 600 /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh
```

Restart SSH:
```bash
systemctl restart sshd
```

### 4. Enable 2FA (Optional)
1. Web UI → Datacenter → Permissions → Two Factor
2. Add TOTP for your user

## Troubleshooting

### Can't Access Web Interface
```bash
# Check pveproxy status
systemctl status pveproxy

# Check if port is listening
ss -tuln | grep 8006

# Check firewall
iptables -L -n
```

### VM Won't Start
```bash
# Check logs
tail -f /var/log/syslog

# Check VM status
qm status <vmid>

# Start manually to see errors
qm start <vmid>
```

### Network Issues
```bash
# Check network configuration
ip a
ip r

# Test connectivity
ping -c 4 8.8.8.8
ping -c 4 google.com
```

## Next Steps

1. Create your first VM or container
2. Set up backup strategy (see SERVICES.md)
3. Configure additional storage if needed
4. Install monitoring (Prometheus/Grafana)

Refer to the [Proxmox Wiki](https://pve.proxmox.com/wiki/Main_Page) for detailed documentation.
