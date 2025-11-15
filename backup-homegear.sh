#!/bin/bash
# Homegear Datenbank Backup Script
# Erstellt ein Backup der Homegear-Datenbank

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="homegear-backup-${TIMESTAMP}.tar.gz"

# Erstelle Backup-Verzeichnis
mkdir -p "${BACKUP_DIR}"

# Stoppe Homegear Container kurz
echo "Stoppe Homegear Container..."
docker-compose stop homegear

# Erstelle Backup
echo "Erstelle Backup: ${BACKUP_FILE}"
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" \
    homegear/data/db.sql* \
    homegear/data/modules \
    homegear/data/scripts

# Starte Homegear wieder
echo "Starte Homegear Container..."
docker-compose up -d homegear

# Zeige Backup-Info
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
echo "✅ Backup erstellt: ${BACKUP_FILE} (${BACKUP_SIZE})"

# Alte Backups löschen (älter als 30 Tage)
find "${BACKUP_DIR}" -name "homegear-backup-*.tar.gz" -mtime +30 -delete
echo "🗑️  Alte Backups (>30 Tage) gelöscht"
