#!/bin/bash
# Smart Home Backup Script
# Sichert alles was NICHT im Git liegt: Datenbanken, Secrets, Laufzeitdaten
# Lädt das Backup automatisch auf OneDrive hoch

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="smarthome-backup-${TIMESTAMP}.tar.gz"
ONEDRIVE_REMOTE="OneDrive:SmartHomeBackups"

# Erstelle Backup-Verzeichnis
mkdir -p "${BACKUP_DIR}"

# Stoppe Homegear Container kurz (DB-Konsistenz)
echo "⏸  Stoppe Homegear Container..."
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" stop homegear

# Erstelle Backup
echo "📦 Erstelle Backup: ${BACKUP_FILE}"
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" \
    -C "${SCRIPT_DIR}" \
    .env \
    homegear/data/db.sql* \
    homegear/data/modules \
    homegear/data/scripts \
    homegear/config/ca/private/ \
    homegear/config/homegear.key \
    openhab/userdata/jsondb/users.json \
    openhab/conf/things/hue.things \
    openhab/conf/things/homeconnect.things \
    openhab/conf/things/weather.things \
    2>/dev/null || true

# Starte Homegear wieder
echo "▶  Starte Homegear Container..."
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" up -d homegear

# Zeige Backup-Info
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
echo "✅ Backup erstellt: ${BACKUP_FILE} (${BACKUP_SIZE})"

# Upload auf OneDrive
echo "☁️  Lade Backup auf OneDrive hoch..."
if rclone copy "${BACKUP_DIR}/${BACKUP_FILE}" "${ONEDRIVE_REMOTE}/" 2>&1; then
    echo "✅ Upload erfolgreich: ${ONEDRIVE_REMOTE}/${BACKUP_FILE}"
else
    echo "❌ Upload fehlgeschlagen! Backup liegt lokal unter: ${BACKUP_DIR}/${BACKUP_FILE}"
fi

# Alte lokale Backups löschen (älter als 30 Tage)
find "${BACKUP_DIR}" -name "smarthome-backup-*.tar.gz" -mtime +30 -delete
echo "🗑️  Alte lokale Backups (>30 Tage) gelöscht"

# Alte OneDrive-Backups löschen (älter als 90 Tage)
rclone delete "${ONEDRIVE_REMOTE}/" --min-age 90d 2>/dev/null || true
echo "🗑️  Alte OneDrive-Backups (>90 Tage) gelöscht"
