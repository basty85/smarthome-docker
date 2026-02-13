#!/bin/bash
# Smart Home Backup Script
# Sichert alles was NICHT im Git liegt: Datenbanken, Secrets, Laufzeitdaten

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="smarthome-backup-${TIMESTAMP}.tar.gz"

# Erstelle Backup-Verzeichnis
mkdir -p "${BACKUP_DIR}"

# Stoppe Homegear Container kurz (DB-Konsistenz)
echo "⏸  Stoppe Homegear Container..."
docker compose stop homegear

# Erstelle Backup
echo "📦 Erstelle Backup: ${BACKUP_FILE}"
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" \
    .env \
    homegear/data/db.sql* \
    homegear/data/modules \
    homegear/data/scripts \
    homegear/config/ca/private/ \
    homegear/config/homegear.key \
    openhab/userdata/jsondb/users.json \
    2>/dev/null || true

# Starte Homegear wieder
echo "▶  Starte Homegear Container..."
docker compose up -d homegear

# Zeige Backup-Info
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
echo "✅ Backup erstellt: ${BACKUP_FILE} (${BACKUP_SIZE})"

# Alte Backups löschen (älter als 30 Tage)
find "${BACKUP_DIR}" -name "smarthome-backup-*.tar.gz" -mtime +30 -delete
echo "🗑️  Alte Backups (>30 Tage) gelöscht"
