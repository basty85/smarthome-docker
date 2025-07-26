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
├── openhab/
│ ├── conf/ # OpenHAB configuration (.items, .rules, .things, .sitemaps, etc.)
│ ├── userdata/ # OpenHAB cache, internal DB, logs
│ └── addons/ # Manually installed add-ons (.jar files)
└── homegear/
├── config/ # Configuration files, e.g. families/enocean.conf
├── data/ # Homegear data, device IDs, keys
└── logs/ # Log output from Homegear
```


---

## 🚀 Getting Started

**Requirements:**

- Docker & Docker Compose installed  
- System has access to USB devices (e.g. `/dev/ttyUSB0` for EnOcean stick)  
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
- Main config is in openhab/conf/

- UI-installed add-ons and internal data are stored in openhab/userdata/

- Manually downloaded .jar add-ons go into openhab/addons/

### Homegear
- EnOcean config is located at homegear/config/families/enocean.conf

- Example device: device = /dev/ttyUSB0 for EnOcean stick

- USB access is passed into the container via devices: in docker-compose.yml

## Web Access
- OpenHAB UI: http://localhost:8080

- OpenHAB HTTPS: https://localhost:8443

- Homegear admin UI (if enabled): Ports 2001 / 2002 / 2003

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

## Notes
- Both containers use network_mode: host to support UDP/multicast and discovery

- USB devices like /dev/ttyUSB0 must exist and be accessible by the Docker runtime

- Do not run native OpenHAB or Homegear in parallel — use Docker only!

## Status
Setup running reliably since: *2018*
Tested on: Raspberry Pi 3, Raspberry Pi 4, Jetson Nano
