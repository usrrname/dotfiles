# Pi NAS — Service Catalog

## Convention

| Layer | Manager | What |
|-------|---------|------|
| System binary | `apt` | Services needing system-level integration (networking, TUN, PAM) |
| Systemd (system) | `systemctl` | Enabled by `setup.sh` |
| Systemd (user) | `systemctl --user` | Defined in `hosts/pi-nas/default.nix` |

## Services

### tailscaled

**Type**: systemd system service  
**Package**: `tailscale` (apt)  
**Config dir**: `/var/lib/tailscale/`  
**Managed by**: `setup.sh` enables system service; `hosts/pi-nas/default.nix` manages user-level serve unit  
**One-time**: `sudo tailscale up && sudo tailscale set --operator=$USER`  
**Purpose**: VPN mesh, gives the Pi a stable Tailscale IP

### tailscale-serve

**Type**: native (persisted by tailscaled)  
**Configured via**: `sudo tailscale set --operator=$USER` then `tailscale serve ...`  
**Ports**: 9090, 3000, 2283 (http), 8384 (syncthing GUI over Tailscale)  
**Notes**: Persists across reboots automatically — no systemd unit needed  
**Check**: `tailscale serve status`

### syncthing

**Type**: systemd user service  
**Package**: `syncthing` (apt)  
**Config dir**: `/mnt/nas/syncthing/`  
**Defined in**: `hosts/pi-nas/default.nix` as `systemd.user.services.syncthing`  
**Unit**: `~/.config/systemd/user/syncthing.service` (HM-managed)  
**Depends on**: `mnt-nas.mount` (waits for BTRFS partition)  
**One-time**: `systemctl --user enable --now syncthing.service`  
**Folders**:
  - personal → `/mnt/nas/syncthing/vaults/personal` (receive-only)
  - rangle → `/mnt/nas/syncthing/vaults/rangle` (receive-only)
  - health → `/mnt/nas/syncthing/vaults/health` (receive-only)

### fail2ban

**Type**: systemd system service  
**Package**: `fail2ban` (apt)  
**Config**: `/etc/fail2ban/`  
**Purpose**: Brute-force protection for SSH

### ufw

**Type**: systemd system service  
**Package**: `ufw` (apt)  
**Purpose**: Firewall  
**Check**: `sudo ufw status verbose`

### docker.io

**Type**: systemd system service  
**Package**: `docker.io` (apt)  
**Purpose**: Container runtime for any Docker Compose services

### nginx

**Type**: systemd system service  
**Package**: `nginx` (apt)  
**Config**: `/etc/nginx/`  
**Purpose**: Reverse proxy / web server

### certbot

**Type**: system-level CLI  
**Package**: `certbot` + python3-certbot-nginx (apt)  
**Purpose**: SSL certs via Let's Encrypt

### restic

**Type**: CLI (run via cron)  
**Package**: `restic` (apt)  
**Purpose**: Offsite backups to Backblaze B2 / S3

### cloudflared

**Type**: systemd system service  
**Package**: `cloudflared` (apt)  
**Purpose**: Cloudflare Tunnel for external access to nginx

### hd-idle

**Type**: systemd system service  
**Package**: `hd-idle` (apt)  
**Purpose**: Spin down HDDs after idle timeout to save power

### avahi-daemon

**Type**: systemd system service  
**Package**: `avahi-daemon` (apt)  
**Purpose**: mDNS/Bonjour so the Pi is discoverable as `house.local`
