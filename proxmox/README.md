# Proxmox Home Server Setup

This directory contains configuration files and scripts for managing a Proxmox VE home server. All configurations are version-controlled via Git for easy backup and restoration.

## Directory Structure

```
proxmox/
├── README.md              # This file
├── configs/               # Proxmox configuration files
│   ├── storage.cfg        # Storage configuration
│   ├── network.cfg        # Network configuration
│   └── datacenter.cfg     # Datacenter-wide settings
├── scripts/               # Automation scripts
│   ├── backup-configs.sh  # Backup Proxmox configs to git
│   ├── restore-configs.sh # Restore configs from git
│   └── setup-cron.sh      # Set up automated backups
├── templates/             # VM and container templates
│   ├── vm/                # Virtual machine configurations
│   └── ct/                # Container (LXC) configurations
└── backups/               # Backup metadata and logs
    └── .gitkeep           # Placeholder for git tracking
```

## Prerequisites

- Proxmox VE 8.x installed on your server
- Git installed on Proxmox host
- SSH access to Proxmox server
- (Optional) GitHub/GitLab account for remote backup

## Quick Start

### 1. Initial Setup on Proxmox Host

SSH into your Proxmox server and clone this repository:

```bash
# Install git if not present
apt update && apt install -y git

# Clone the repository
cd /root
git clone https://github.com/Nikhilvedi/xyz.git
cd xyz/proxmox

# Make scripts executable
chmod +x scripts/*.sh
```

### 2. Configure Git on Proxmox

```bash
# Configure git identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set up SSH key for passwordless push (recommended)
ssh-keygen -t ed25519 -C "proxmox-server"
cat ~/.ssh/id_ed25519.pub
# Add this public key to your GitHub/GitLab account
```

### 3. Backup Current Configuration

Run the backup script to capture your current Proxmox configuration:

```bash
./scripts/backup-configs.sh
```

### 4. Set Up Automated Backups

Schedule automatic configuration backups:

```bash
./scripts/setup-cron.sh
```

## Configuration Files

### Storage Configuration (`configs/storage.cfg`)

Defines storage backends for VMs and containers:
- Local storage
- NFS/CIFS mounts
- ZFS pools
- Ceph clusters

### Network Configuration (`configs/network.cfg`)

Defines network interfaces and bridges:
- Management interface
- VM bridge networks
- VLAN configurations

### Datacenter Configuration (`configs/datacenter.cfg`)

Datacenter-wide settings:
- Backup schedules
- HA settings
- User permissions

## VM and Container Templates

### Virtual Machine Templates (`templates/vm/`)

Store your VM configurations as `.conf` files. These can be restored to recreate VMs with the same settings.

### Container Templates (`templates/ct/`)

Store LXC container configurations. Useful for quickly spinning up identical containers.

## Backup Strategy

### What Gets Backed Up

1. **Proxmox Configuration** (`/etc/pve/`)
   - VM configurations
   - Container configurations
   - Storage definitions
   - Network configurations
   - User/permission settings

2. **Custom Scripts**
   - Automation scripts
   - Cron jobs

3. **Template Definitions**
   - VM templates
   - Container templates

### What Does NOT Get Backed Up

- VM disk images (use Proxmox Backup Server for this)
- Container volumes
- ISO images
- Large binary files

### Recommended Backup Schedule

| Backup Type | Frequency | Retention |
|------------|-----------|-----------|
| Config files | Daily | 30 days |
| VM/CT configs | On change | Permanent |
| Full VM backup | Weekly | 4 weeks |

## Restoring Configuration

To restore your Proxmox configuration from this repository:

```bash
# On a fresh Proxmox installation
./scripts/restore-configs.sh
```

**Warning**: Always test restoration on a non-production system first!

## Security Considerations

1. **Sensitive Data**: Never commit passwords or API keys. Use Proxmox's built-in secrets management.

2. **SSH Keys**: The backup script excludes SSH private keys by default.

3. **Access Control**: Ensure your git repository is private if it contains sensitive network configurations.

## Common Tasks

### Adding a New VM Configuration

1. Create VM in Proxmox web interface
2. Run backup script: `./scripts/backup-configs.sh`
3. Commit changes: `git add . && git commit -m "Add new VM: <name>"`
4. Push to remote: `git push`

### Updating Network Configuration

1. Make changes in Proxmox web interface or edit `/etc/network/interfaces`
2. Test the configuration
3. Run: `./scripts/backup-configs.sh`
4. Review and commit changes

## Troubleshooting

### Git Push Fails

```bash
# Check remote configuration
git remote -v

# Verify SSH key is added
ssh -T git@github.com
```

### Configuration Not Syncing

```bash
# Check cron job status
crontab -l

# View backup logs
cat /var/log/proxmox-backup.log
```

## Contributing

Feel free to customize these scripts and configurations for your specific needs. If you make improvements that could benefit others, consider contributing back!

## License

MIT License - See LICENSE file for details.
