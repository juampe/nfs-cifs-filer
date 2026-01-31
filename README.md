# NFS-CIFS-Filer

[![Docker Image](https://img.shields.io/docker/pulls/juampe/nfs-cifs-filer.svg)](https://hub.docker.com/r/juampe/nfs-cifs-filer)
[![Docker Image Size](https://img.shields.io/docker/image-size/juampe/nfs-cifs-filer/latest.svg)](https://hub.docker.com/r/juampe/nfs-cifs-filer)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A versatile multi-protocol file sharing container supporting NFS, CIFS/SMB, DLNA, and Windows Network Discovery.

## Features

- 🗂️ **NFS Server**: NFSv3 and NFSv4 support for Linux/Unix clients
- 💼 **Samba/CIFS**: SMB1/SMB2/SMB3 support for Windows, macOS, and Linux
- 📺 **MiniDLNA**: DLNA/UPnP media server for streaming to devices
- 🔍 **WSDD**: Windows Service Discovery for network visibility
- 🏥 **Healthcheck**: Automatic service monitoring
- 🏗️ **Multi-arch**: Supports amd64, arm64, and armv7
- 🔐 **Legacy & Modern**: Compatible from Windows 98 to Windows 11

## Quick Start

### Basic Usage

```bash
docker run -d \
  --name filer \
  --hostname filer \
  --privileged \
  -p 2049:2049 \
  -p 445:445 \
  -p 139:139 \
  -p 8200:8200 \
  -v /path/to/exports:/etc/exports \
  -v /path/to/samba/config:/etc/samba \
  -v /path/to/shared/data:/data \
  juampe/nfs-cifs-filer:latest
```

### Docker Compose

```yaml
version: '3.8'

services:
  filer:
    image: juampe/nfs-cifs-filer:latest
    container_name: filer
    hostname: filer
    privileged: true
    restart: unless-stopped
    environment:
      - TZ=America/New_York
    ports:
      - "2049:2049"     # NFS
      - "111:111"       # RPC
      - "445:445"       # SMB
      - "139:139"       # NetBIOS
      - "8200:8200"     # MiniDLNA Web UI
    volumes:
      - ./exports:/etc/exports
      - ./samba/etc:/etc/samba
      - ./samba/lib:/var/lib/samba
      - ./minidlna.conf:/etc/minidlna.conf
      - /path/to/data:/data
```

## Configuration

### NFS Configuration

Create an `/etc/exports` file:

```bash
# NFSv3 and NFSv4 compatible export
/data    192.168.1.0/24(rw,fsid=0,nohide,insecure,no_root_squash,no_subtree_check,sync,crossmnt)
```

**Key options:**
- `fsid=0`: Makes this the root for NFSv4 clients
- `crossmnt`: Allow crossing mount points
- `no_root_squash`: Preserve root user permissions
- `no_subtree_check`: Improve reliability

### Samba Configuration

Minimal `/etc/samba/smb.conf`:

```ini
[global]
    workgroup = WORKGROUP
    server string = File Server
    security = user
    
    # Multi-version Windows support
    server min protocol = NT1
    server max protocol = SMB3
    
    # Authentication
    lanman auth = yes
    ntlm auth = yes
    
    # SMB3 encryption (optional)
    smb encrypt = auto

[shared]
    path = /data
    browseable = yes
    writable = yes
    valid users = @users
    create mask = 0664
    directory mask = 0775
```

### MiniDLNA Configuration

Basic `/etc/minidlna.conf`:

```ini
media_dir=V,/data/videos
media_dir=A,/data/music
media_dir=P,/data/pictures
friendly_name=Media Server
inotify=yes
```

## Mounting Shares

### NFS Clients

**Linux:**
```bash
# NFSv4 (recommended)
sudo mount -t nfs -o vers=4 server.ip:/ /mnt/share

# NFSv3 (legacy compatibility)
sudo mount -t nfs -o vers=3 server.ip:/data /mnt/share
```

**macOS:**
```bash
sudo mount -t nfs server.ip:/data /Volumes/share
```

**Docker volume:**
```bash
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=server.ip,vers=4,rw \
  --opt device=:/ \
  nfs-data
```

### CIFS/SMB Clients

**Windows:**
```cmd
net use Z: \\server.ip\shared /user:username password
```

**Linux:**
```bash
sudo mount -t cifs //server.ip/shared /mnt/share \
  -o username=user,password=pass,vers=3.0
```

**macOS:**
```bash
mount -t smbfs //username:password@server.ip/shared /Volumes/share
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `UTC` | Timezone (e.g., `America/New_York`) |
| `S6_VERBOSITY` | `2` | s6-overlay verbosity level (0-5) |
| `S6_CMD_WAIT_FOR_SERVICES_MAXTIME` | `0` | Max time to wait for services (0=unlimited) |

## Volumes

| Container Path | Description |
|---------------|-------------|
| `/etc/exports` | NFS exports configuration file |
| `/etc/samba` | Samba configuration directory |
| `/var/lib/samba` | Samba database and state files |
| `/etc/minidlna.conf` | MiniDLNA configuration file |
| `/data` | Default shared data directory |

## Ports

| Port | Protocol | Service |
|------|----------|---------|
| 2049 | TCP/UDP | NFS |
| 111 | TCP/UDP | RPC (portmapper) |
| 445 | TCP | SMB/CIFS |
| 139 | TCP | NetBIOS |
| 137-138 | UDP | NetBIOS |
| 8200 | TCP | MiniDLNA Web UI |
| 1900 | UDP | DLNA/UPnP Discovery |

## Architecture

This container uses:
- **Base**: Debian Bullseye Slim
- **Init system**: s6-overlay v3.2.2.0
- **NFS**: kernel NFS server (nfs-kernel-server)
- **Samba**: Samba 4.x with AD DC support
- **DLNA**: MiniDLNA 1.3.x
- **WSDD**: Windows Service Discovery daemon

### Service Dependencies

```
s6-overlay
├── rpcbind (RPC services)
│   └── nfs-server (NFS daemon)
├── samba (SMB/CIFS server)
│   └── wsdd (Windows discovery)
└── minidlna (DLNA media server)
```

## Building

### Local Build

```bash
docker build -t nfs-cifs-filer:latest .
```

### Multi-arch Build

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  --tag juampe/nfs-cifs-filer:latest \
  --push .
```

## Healthcheck

The container includes automatic health monitoring:

- ✅ **Samba** (port 445, smbd process)
- ✅ **NFS** (rpc.mountd, nfsd processes)
- ⚠️ **WSDD** (warning only)
- ⚠️ **MiniDLNA** (warning only)

Check health status:
```bash
docker inspect filer --format='{{.State.Health.Status}}'
```

## Protocol Compatibility

### NFS Versions

| Version | Ports | Features | Use Case |
|---------|-------|----------|----------|
| **NFSv3** | Multiple + 2049 | Stateless, legacy support | Maximum compatibility |
| **NFSv4** | 2049 only | Stateful, ACLs, Kerberos | Modern networks, firewall-friendly |

### SMB/CIFS Versions

| Version | Windows Support | Features |
|---------|----------------|----------|
| **SMB1/NT1** | 98/2000/XP | LANMAN auth, no encryption |
| **SMB2** | Vista/7 | NTLMv2, improved performance |
| **SMB3** | 8/10/11 | AES encryption, multichannel |

## Security Considerations

- Container requires `--privileged` for NFS kernel module access
- Consider using capabilities: `--cap-add=SYS_ADMIN --cap-add=SYS_MODULE`
- SMB1 is enabled for legacy support - disable if not needed
- Use strong passwords for Samba users
- Restrict NFS exports to specific networks

## Troubleshooting

### NFS not mounting

1. Check exports: `docker exec filer exportfs -v`
2. Verify NFS versions: `docker exec filer cat /proc/fs/nfsd/versions`
3. Ensure container is privileged
4. Check firewall rules on host

### Samba not visible on network

1. Verify WSDD is running: `docker exec filer ps aux | grep wsdd`
2. Check workgroup matches: `docker exec filer testparm -s | grep workgroup`
3. Ensure ports 137-139, 445 are accessible
4. Check Windows network discovery is enabled

### Permission issues

1. Set proper ownership on shared directories
2. Configure Samba user: `docker exec filer smbpasswd -a username`
3. Check NFS export options (`no_root_squash`, etc.)

## Examples

### Personal Cloud Storage

```yaml
services:
  filer:
    image: juampe/nfs-cifs-filer:latest
    privileged: true
    volumes:
      - ./exports:/etc/exports
      - ./samba:/etc/samba
      - /home/user/cloud:/data
  
  nextcloud:
    image: nextcloud:latest
    volumes:
      - nfs-data:/var/www/html/data

volumes:
  nfs-data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=filer,vers=4
      device: :/
```

### Media Server

```yaml
services:
  filer:
    image: juampe/nfs-cifs-filer:latest
    privileged: true
    ports:
      - "8200:8200"  # MiniDLNA
    volumes:
      - ./minidlna.conf:/etc/minidlna.conf
      - /media/library:/data:ro
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

**Key points:**
- ✅ Free to use, modify, and distribute
- ✅ Source code must be made available
- ✅ Derivative works must also be GPL v3
- ✅ No warranty provided

## Links

- **Docker Hub**: https://hub.docker.com/r/juampe/nfs-cifs-filer
- **GitHub**: https://github.com/juampe/nfs-cifs-filer
- **Issues**: https://github.com/juampe/nfs-cifs-filer/issues

## Credits

Built with:
- [s6-overlay](https://github.com/just-containers/s6-overlay) - Process supervision
- [Samba](https://www.samba.org/) - SMB/CIFS implementation
- [NFS Kernel Server](https://linux-nfs.org/) - Linux NFS server
- [MiniDLNA](https://sourceforge.net/projects/minidlna/) - DLNA media server
- [WSDD](https://github.com/christgau/wsdd) - Windows Service Discovery
