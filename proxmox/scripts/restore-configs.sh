#!/bin/bash
#
# restore-configs.sh
# Restores Proxmox configuration files from this git repository
#
# Usage: ./restore-configs.sh [--dry-run]
#
# WARNING: This will overwrite existing Proxmox configurations!
# Always test on a non-production system first.
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXMOX_DIR="$(dirname "$SCRIPT_DIR")"
CONFIGS_DIR="$PROXMOX_DIR/configs"
TEMPLATES_DIR="$PROXMOX_DIR/templates"
BACKUP_DIR="/var/backup/proxmox-restore-$(date '+%Y%m%d_%H%M%S')"
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--dry-run]"
            exit 1
            ;;
    esac
done

info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

dry_run_msg() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would: $*"
    fi
}

# Check if running on Proxmox
check_proxmox() {
    if [ ! -d "/etc/pve" ]; then
        error "This script must be run on a Proxmox VE host"
        exit 1
    fi
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Create backup of current configuration
create_backup() {
    info "Creating backup of current configuration..."
    
    if [ "$DRY_RUN" = true ]; then
        dry_run_msg "Create backup directory at $BACKUP_DIR"
        return
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup current configs
    cp /etc/pve/storage.cfg "$BACKUP_DIR/" 2>/dev/null || true
    cp /etc/pve/datacenter.cfg "$BACKUP_DIR/" 2>/dev/null || true
    cp /etc/pve/user.cfg "$BACKUP_DIR/" 2>/dev/null || true
    cp /etc/network/interfaces "$BACKUP_DIR/network.cfg" 2>/dev/null || true
    
    # Backup VM configs
    cp -r /etc/pve/qemu-server "$BACKUP_DIR/" 2>/dev/null || true
    
    # Backup container configs
    cp -r /etc/pve/lxc "$BACKUP_DIR/" 2>/dev/null || true
    
    info "  ✓ Current configuration backed up to: $BACKUP_DIR"
}

# Restore storage configuration
restore_storage() {
    info "Restoring storage configuration..."
    
    if [ -f "$CONFIGS_DIR/storage.cfg" ]; then
        if [ "$DRY_RUN" = true ]; then
            dry_run_msg "Copy $CONFIGS_DIR/storage.cfg to /etc/pve/storage.cfg"
        else
            cp "$CONFIGS_DIR/storage.cfg" /etc/pve/storage.cfg
            info "  ✓ Restored storage.cfg"
        fi
    else
        warn "  No storage.cfg found in repository"
    fi
}

# Restore datacenter configuration
restore_datacenter() {
    info "Restoring datacenter configuration..."
    
    if [ -f "$CONFIGS_DIR/datacenter.cfg" ]; then
        if [ "$DRY_RUN" = true ]; then
            dry_run_msg "Copy $CONFIGS_DIR/datacenter.cfg to /etc/pve/datacenter.cfg"
        else
            cp "$CONFIGS_DIR/datacenter.cfg" /etc/pve/datacenter.cfg
            info "  ✓ Restored datacenter.cfg"
        fi
    else
        warn "  No datacenter.cfg found in repository"
    fi
}

# Restore network configuration
restore_network() {
    info "Restoring network configuration..."
    
    if [ -f "$CONFIGS_DIR/network.cfg" ]; then
        if [ "$DRY_RUN" = true ]; then
            dry_run_msg "Copy $CONFIGS_DIR/network.cfg to /etc/network/interfaces"
            dry_run_msg "Run 'ifreload -a' to apply network changes"
        else
            cp "$CONFIGS_DIR/network.cfg" /etc/network/interfaces
            info "  ✓ Restored network configuration"
            warn "  ⚠ Network configuration restored. Run 'ifreload -a' to apply."
            warn "  ⚠ WARNING: This may disconnect your SSH session!"
        fi
    else
        warn "  No network.cfg found in repository"
    fi
}

# Restore VM configurations
restore_vm_configs() {
    info "Restoring VM configurations..."
    
    if [ -d "$TEMPLATES_DIR/vm" ]; then
        for vm_conf in "$TEMPLATES_DIR/vm"/*.conf; do
            if [ -f "$vm_conf" ]; then
                vm_id=$(basename "$vm_conf" .conf)
                if [ "$DRY_RUN" = true ]; then
                    dry_run_msg "Copy $vm_conf to /etc/pve/qemu-server/${vm_id}.conf"
                else
                    cp "$vm_conf" "/etc/pve/qemu-server/${vm_id}.conf"
                    info "  ✓ Restored VM $vm_id configuration"
                fi
            fi
        done
    else
        info "  No VM configurations to restore"
    fi
}

# Restore container configurations
restore_ct_configs() {
    info "Restoring container configurations..."
    
    if [ -d "$TEMPLATES_DIR/ct" ]; then
        for ct_conf in "$TEMPLATES_DIR/ct"/*.conf; do
            if [ -f "$ct_conf" ]; then
                ct_id=$(basename "$ct_conf" .conf)
                if [ "$DRY_RUN" = true ]; then
                    dry_run_msg "Copy $ct_conf to /etc/pve/lxc/${ct_id}.conf"
                else
                    cp "$ct_conf" "/etc/pve/lxc/${ct_id}.conf"
                    info "  ✓ Restored container $ct_id configuration"
                fi
            fi
        done
    else
        info "  No container configurations to restore"
    fi
}

# Confirmation prompt
confirm_restore() {
    if [ "$DRY_RUN" = true ]; then
        return 0
    fi
    
    echo ""
    echo "========================================"
    echo -e "${RED}WARNING: This will overwrite your current Proxmox configuration!${NC}"
    echo "========================================"
    echo ""
    echo "A backup of your current configuration will be saved to: $BACKUP_DIR"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        info "Restore cancelled."
        exit 0
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "Proxmox Configuration Restore"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}(DRY RUN - No changes will be made)${NC}"
    fi
    echo "=========================================="
    
    check_proxmox
    check_root
    
    confirm_restore
    create_backup
    
    restore_storage
    restore_datacenter
    # Uncomment the following line if you want to restore network config
    # restore_network
    restore_vm_configs
    restore_ct_configs
    
    echo ""
    echo "=========================================="
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}Dry run complete. No changes were made.${NC}"
    else
        echo -e "${GREEN}Restore complete!${NC}"
        echo ""
        echo "Notes:"
        echo "  - A backup of your previous configuration is at: $BACKUP_DIR"
        echo "  - Network configuration was NOT restored automatically."
        echo "    To restore network config, edit /etc/network/interfaces manually."
        echo "  - Restart pveproxy to apply some changes: systemctl restart pveproxy"
    fi
    echo "=========================================="
}

main
