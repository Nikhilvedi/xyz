# Home Server Services Guide
# 
# This document outlines common services you might want to run
# on your Proxmox home server, with recommended configurations.

## Recommended Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Proxmox VE Host                            │
├──────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Home Server   │  │   Docker Host   │  │   Media Server  │  │
│  │      (VM)       │  │    (LXC/VM)     │  │      (VM)       │  │
│  │                 │  │                 │  │                 │  │
│  │ - Home Asst.    │  │ - Portainer     │  │ - Plex/Jellyfin │  │
│  │ - Pi-hole       │  │ - Various       │  │ - *arr stack    │  │
│  │ - Unifi Ctrl    │  │   containers    │  │                 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   NAS/Storage   │  │    Dev/Test     │  │   Monitoring    │  │
│  │    (LXC/VM)     │  │      (VM)       │  │     (LXC)       │  │
│  │                 │  │                 │  │                 │  │
│  │ - TrueNAS       │  │ - Development   │  │ - Grafana       │  │
│  │ - OpenMediaVault│  │ - Testing       │  │ - Prometheus    │  │
│  │ - Samba         │  │                 │  │ - Uptime Kuma   │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

## Core Services

### 1. Network Services

| Service | Type | Purpose | Resources |
|---------|------|---------|-----------|
| Pi-hole | LXC | DNS-level ad blocking | 1 core, 512MB RAM |
| Unifi Controller | LXC/Docker | Network management | 2 cores, 2GB RAM |
| WireGuard | LXC | VPN server | 1 core, 256MB RAM |
| Nginx Proxy Manager | Docker | Reverse proxy | 1 core, 512MB RAM |

### 2. Home Automation

| Service | Type | Purpose | Resources |
|---------|------|---------|-----------|
| Home Assistant | VM | Smart home hub | 2 cores, 4GB RAM |
| Zigbee2MQTT | Docker | Zigbee gateway | 1 core, 256MB RAM |
| Node-RED | Docker | Automation flows | 1 core, 512MB RAM |
| MQTT Broker | Docker | Message broker | 1 core, 256MB RAM |

### 3. Media Services

| Service | Type | Purpose | Resources |
|---------|------|---------|-----------|
| Plex/Jellyfin | VM | Media streaming | 4 cores, 8GB RAM* |
| Sonarr | Docker | TV show management | 1 core, 1GB RAM |
| Radarr | Docker | Movie management | 1 core, 1GB RAM |
| Prowlarr | Docker | Indexer manager | 1 core, 512MB RAM |
| qBittorrent | Docker | Download client | 1 core, 1GB RAM |

*Adjust based on transcoding needs; consider GPU passthrough.

### 4. Storage & Backup

| Service | Type | Purpose | Resources |
|---------|------|---------|-----------|
| TrueNAS | VM | NAS with ZFS | 2 cores, 8GB+ RAM |
| Syncthing | Docker | File sync | 1 core, 512MB RAM |
| Duplicati | Docker | Cloud backup | 1 core, 1GB RAM |
| Proxmox Backup Server | VM | VM/CT backups | 2 cores, 4GB RAM |

### 5. Monitoring & Management

| Service | Type | Purpose | Resources |
|---------|------|---------|-----------|
| Grafana | Docker | Dashboards | 1 core, 512MB RAM |
| Prometheus | Docker | Metrics collection | 1 core, 1GB RAM |
| Uptime Kuma | Docker | Uptime monitoring | 1 core, 256MB RAM |
| Portainer | Docker | Container management | 1 core, 512MB RAM |

## Network Configuration Tips

### Recommended VLANs

| VLAN ID | Name | Purpose | Subnet |
|---------|------|---------|--------|
| 1 | Management | Proxmox, switches | 192.168.1.0/24 |
| 10 | Servers | VMs and containers | 192.168.10.0/24 |
| 20 | IoT | Smart home devices | 192.168.20.0/24 |
| 30 | Guest | Guest WiFi | 192.168.30.0/24 |

### IP Address Planning

Reserve static IPs for critical services:
- 192.168.1.1 - Router/Gateway
- 192.168.1.2 - Proxmox Host
- 192.168.1.3 - Pi-hole (Primary DNS)
- 192.168.1.4 - Secondary DNS
- 192.168.1.10-50 - VMs and Containers
- 192.168.1.100+ - DHCP range

## Quick Start Guides

### Setting Up Pi-hole in LXC

```bash
# Create container
pct create 100 local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst \
  --hostname pihole \
  --memory 512 \
  --cores 1 \
  --rootfs local-lvm:8 \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.1.3/24,gw=192.168.1.1

# Start and install Pi-hole
pct start 100
pct exec 100 -- bash -c "curl -sSL https://install.pi-hole.net | bash"
```

### Setting Up Docker in LXC

```bash
# Create unprivileged container with nesting
pct create 101 local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst \
  --hostname docker \
  --memory 4096 \
  --cores 4 \
  --rootfs local-lvm:50 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --features nesting=1,keyctl=1 \
  --unprivileged 1

# Start and install Docker
pct start 101
pct exec 101 -- bash -c "apt update && apt install -y curl && curl -fsSL https://get.docker.com | sh"
```

## Backup Strategy

1. **Configuration** (this repo)
   - Frequency: Daily
   - Method: Git backup scripts
   - Retention: Permanent

2. **VM/Container Data**
   - Frequency: Daily incremental, Weekly full
   - Method: Proxmox Backup Server
   - Retention: 4 weeks

3. **Critical Data**
   - Frequency: Daily
   - Method: Off-site backup (cloud)
   - Retention: 90 days
