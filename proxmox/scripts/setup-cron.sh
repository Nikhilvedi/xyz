#!/bin/bash
#
# setup-cron.sh
# Sets up automated backup cron job for Proxmox configuration
#
# Usage: ./setup-cron.sh [--remove]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/backup-configs.sh"
CRON_FILE="/etc/cron.d/proxmox-config-backup"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Remove cron job
remove_cron() {
    if [ -f "$CRON_FILE" ]; then
        rm "$CRON_FILE"
        info "Removed cron job: $CRON_FILE"
    else
        info "No cron job found to remove"
    fi
    exit 0
}

# Setup cron job
setup_cron() {
    info "Setting up automated backup cron job..."
    
    # Create cron file
    cat > "$CRON_FILE" << EOF
# Proxmox configuration backup
# Runs daily at 2:00 AM
# 
# This cron job backs up Proxmox configuration to git
# Edit the schedule below as needed (minute hour day month weekday)

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Daily backup at 2:00 AM
0 2 * * * root $BACKUP_SCRIPT "Automated daily backup" >> /var/log/proxmox-backup.log 2>&1

# Weekly full backup on Sunday at 3:00 AM (optional - uncomment if needed)
# 0 3 * * 0 root $BACKUP_SCRIPT "Automated weekly backup" >> /var/log/proxmox-backup.log 2>&1
EOF

    chmod 644 "$CRON_FILE"
    
    info "✓ Cron job installed: $CRON_FILE"
    info ""
    info "Backup schedule:"
    info "  - Daily at 2:00 AM"
    info ""
    info "Log file: /var/log/proxmox-backup.log"
    info ""
    info "To modify the schedule, edit: $CRON_FILE"
    info "To remove the cron job, run: $0 --remove"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --remove)
            check_root
            remove_cron
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--remove]"
            exit 1
            ;;
    esac
done

# Main
check_root

echo "=========================================="
echo "Proxmox Automated Backup Setup"
echo "=========================================="

# Check if backup script exists
if [ ! -f "$BACKUP_SCRIPT" ]; then
    error "Backup script not found: $BACKUP_SCRIPT"
    exit 1
fi

# Make sure backup script is executable
chmod +x "$BACKUP_SCRIPT"

setup_cron

echo "=========================================="
echo -e "${GREEN}Setup complete!${NC}"
echo "=========================================="
