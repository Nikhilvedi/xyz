#!/bin/bash
#
# backup-configs.sh
# Backs up Proxmox configuration files to this git repository
#
# Usage: ./backup-configs.sh [commit-message]
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXMOX_DIR="$(dirname "$SCRIPT_DIR")"
CONFIGS_DIR="$PROXMOX_DIR/configs"
TEMPLATES_DIR="$PROXMOX_DIR/templates"
LOG_FILE="/var/log/proxmox-backup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

info() {
    log "INFO" "${GREEN}$*${NC}"
}

warn() {
    log "WARN" "${YELLOW}$*${NC}"
}

error() {
    log "ERROR" "${RED}$*${NC}"
}

# Check if running on Proxmox
check_proxmox() {
    if [ ! -d "/etc/pve" ]; then
        error "This script must be run on a Proxmox VE host"
        error "Cannot find /etc/pve directory"
        exit 1
    fi
}

# Backup Proxmox configuration
backup_pve_config() {
    info "Backing up Proxmox configuration..."
    
    # Storage configuration
    if [ -f "/etc/pve/storage.cfg" ]; then
        cp /etc/pve/storage.cfg "$CONFIGS_DIR/storage.cfg"
        info "  ✓ Backed up storage.cfg"
    fi
    
    # Datacenter configuration
    if [ -f "/etc/pve/datacenter.cfg" ]; then
        cp /etc/pve/datacenter.cfg "$CONFIGS_DIR/datacenter.cfg"
        info "  ✓ Backed up datacenter.cfg"
    fi
    
    # User configuration
    if [ -f "/etc/pve/user.cfg" ]; then
        cp /etc/pve/user.cfg "$CONFIGS_DIR/user.cfg"
        info "  ✓ Backed up user.cfg"
    fi
    
    # Firewall configuration
    if [ -d "/etc/pve/firewall" ]; then
        mkdir -p "$CONFIGS_DIR/firewall"
        cp -r /etc/pve/firewall/* "$CONFIGS_DIR/firewall/" 2>/dev/null || true
        info "  ✓ Backed up firewall configuration"
    fi
}

# Backup network configuration
backup_network_config() {
    info "Backing up network configuration..."
    
    if [ -f "/etc/network/interfaces" ]; then
        cp /etc/network/interfaces "$CONFIGS_DIR/network.cfg"
        info "  ✓ Backed up network interfaces"
    fi
}

# Backup VM configurations
backup_vm_configs() {
    info "Backing up VM configurations..."
    
    mkdir -p "$TEMPLATES_DIR/vm"
    
    # Find all QEMU VM configurations
    if [ -d "/etc/pve/qemu-server" ]; then
        for vm_conf in /etc/pve/qemu-server/*.conf; do
            if [ -f "$vm_conf" ]; then
                vm_id=$(basename "$vm_conf" .conf)
                # Copy configuration, removing only SMBIOS (contains unique identifiers)
                grep -v "smbios1:" "$vm_conf" > "$TEMPLATES_DIR/vm/${vm_id}.conf" || true
                info "  ✓ Backed up VM $vm_id"
            fi
        done
    fi
}

# Backup container configurations
backup_ct_configs() {
    info "Backing up container configurations..."
    
    mkdir -p "$TEMPLATES_DIR/ct"
    
    # Find all LXC container configurations
    if [ -d "/etc/pve/lxc" ]; then
        for ct_conf in /etc/pve/lxc/*.conf; do
            if [ -f "$ct_conf" ]; then
                ct_id=$(basename "$ct_conf" .conf)
                # Copy container configuration as-is
                cp "$ct_conf" "$TEMPLATES_DIR/ct/${ct_id}.conf" || true
                info "  ✓ Backed up container $ct_id"
            fi
        done
    fi
}

# Backup custom cron jobs
backup_cron() {
    info "Backing up cron configuration..."
    
    mkdir -p "$CONFIGS_DIR/cron"
    
    # Root crontab
    crontab -l > "$CONFIGS_DIR/cron/root-crontab" 2>/dev/null || true
    
    # System cron.d files (excluding defaults)
    for cronfile in /etc/cron.d/*; do
        if [ -f "$cronfile" ]; then
            filename=$(basename "$cronfile")
            # Skip default system files
            if [[ "$filename" != "e2scrub_all" && "$filename" != "popularity-contest" ]]; then
                cp "$cronfile" "$CONFIGS_DIR/cron/$filename" 2>/dev/null || true
            fi
        fi
    done
    
    info "  ✓ Backed up cron configuration"
}

# Commit and push changes
commit_changes() {
    local commit_msg="${1:-Automated backup: $(date '+%Y-%m-%d %H:%M:%S')}"
    
    info "Committing changes to git..."
    
    cd "$PROXMOX_DIR"
    
    # Check if there are changes
    if git diff --quiet && git diff --cached --quiet; then
        info "No changes to commit"
        return 0
    fi
    
    git add .
    git commit -m "$commit_msg"
    
    # Push if remote is configured
    if git remote -v | grep -q origin; then
        info "Pushing to remote repository..."
        git push origin HEAD 2>/dev/null || warn "Failed to push. Check your SSH keys or remote configuration."
    else
        warn "No remote 'origin' configured. Changes committed locally only."
    fi
    
    info "✓ Backup complete!"
}

# Main execution
main() {
    info "=========================================="
    info "Proxmox Configuration Backup"
    info "=========================================="
    
    check_proxmox
    
    backup_pve_config
    backup_network_config
    backup_vm_configs
    backup_ct_configs
    backup_cron
    
    commit_changes "$1"
    
    info "=========================================="
    info "Backup completed successfully!"
    info "=========================================="
}

main "$@"
