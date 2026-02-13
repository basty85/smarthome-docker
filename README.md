# 🏠 Smart Home Docker Setup

This project provides a Docker-based environment for a complex Smart Home system using:

- **OpenHAB**: Central automation platform for ZigBee, Z-Wave, and more
- **Homegear**: Bridge for EnOcean components like shutters, switches, etc.
- All configuration data is versioned and stored outside the containers

---

## 📁 Project Structure

```bash
smarthome-docker/
├── docker-compose.yml
├── README.md
├── backup-homegear.sh
├── update-homegear-db.sh
├── openhab/
│   ├── conf/           # OpenHAB configuration (.items, .rules, .things, .sitemaps, etc.)
│   ├── userdata/       # OpenHAB cache, internal DB, logs
│   └── addons/         # Manually installed add-ons (.jar files)
└── homegear/
    ├── config/         # Configuration files, e.g. families/enocean.conf
    ├── data/           # Homegear data, device IDs, keys
    ├── logs/           # Log output from Homegear
    ├── admin-ui/       # Homegear Admin UI
    ├── ui/             # Homegear Web UI
    └── db.sql*         # SQLite database files
```


---

## 🚀 Getting Started

**Requirements:**

- Docker & Docker Compose installed
- System has access to USB devices:
  - **Z-Wave**: Aeotec Z-Stick 7 (mapped to `/dev/zwave`)
  - **EnOcean**: USB300 Stick with FTDI FT232R (mapped to `/dev/ttyUSB0`)
- Existing configuration files for OpenHAB and Homegear

### Start

```bash
cd ~/smarthome-docker
docker compose up -d
```


### Stop

```bash
docker compose down
```

## Configuration Details


### OpenHAB
- **Main config**: `openhab/conf/` (items, things, rules, sitemaps)
- **Things configured**:
  - Z-Wave devices (Qubino Flush relays and dimmers)
  - Philips Hue Bridge at `192.168.1.33`
- **UI-installed add-ons** and internal data: `openhab/userdata/`
- **Manually downloaded .jar add-ons**: `openhab/addons/`
- **Ports**: HTTP on `8080`, HTTPS on `8443`

### Homegear
- **EnOcean config**: `homegear/config/families/enocean.conf`
- **Device mapping**: `/dev/ttyUSB0` (FTDI FT232R USB UART)
- **Database**: SQLite database files in `homegear/` directory
- **Admin UI**: Available via Homegear web interface
- **Backup scripts**: `backup-homegear.sh` and `update-homegear-db.sh`
- USB access is passed into the container via `devices:` in docker-compose.yml

## 🌐 Web Access
- **OpenHAB UI**: http://localhost:8080
- **OpenHAB HTTPS**: https://localhost:8443
- **Homegear Admin UI**: Access via web interface (ports 2001 / 2002 / 2003 if enabled)

## Live Reload & Persistence
- Changes to .rules, .items, .things take effect immediately without restart

- Add-ons and states persist due to volume binding

- Homegear saves device pairing and communication data in data/

## Backup & Version Control
### Versioning via Git
1. Example .gitignore:

```bash
openhab/userdata/
homegear/logs/
```

2. Initialize:

```bash
git init
git add .
git commit -m "Initial Smart Home Docker Setup"
```

### Backup Suggestion
Back up the entire smarthome-docker/ directory regularly, or use a cronjob to archive it.

## 📝 Notes
- Both containers use `network_mode: host` to support UDP/multicast and device discovery
- USB devices are mapped by ID (not by `/dev/ttyUSB*`) for stability:
  - **Z-Wave**: `usb-Silicon_Labs_CP2102N_USB_to_UART_Bridge_Controller_*` → `/dev/zwave`
  - **EnOcean**: `usb-FTDI_FT232R_USB_UART_*` → `/dev/ttyUSB0`
- Timezone is set to `Europe/Berlin`
- Do not run native OpenHAB or Homegear in parallel — use Docker only!

## ✅ Status
- **Running reliably since**: 2018
- **Last updated**: November 2025
- **Tested on**: Raspberry Pi 3, Raspberry Pi 4, Jetson Nano
- **Z-Wave devices**: Qubino Flush 1 Relay (ZMNHAD), Qubino Flush Dimmer (ZMNHDD)
- **Smart Home systems**: Z-Wave, EnOcean, Philips Hue
