#!/bin/bash

# Configuration des chemins et des variables
SOURCE_DIR="/var/spool/asterisk/backup"
DEST_HOST="pabx@192.168.6.150"
DEST_DIR="/home/pabx/backup"
SSH_KEY="/home/asterisk/.ssh/id_rsa"
LOG_FILE="/var/log/backup.log"
MAIL_RECIPIENT="moussaoutaleb@gmail.com"

# Récupère le fichier de sauvegarde le plus récent (< 1h)
BACKUP_FILE=$(find "$SOURCE_DIR" -name "*.tar.gz" -mmin -60 | tail -n 1)

# Vérifie si un fichier de sauvegarde a été trouvé
if [ -z "$BACKUP_FILE" ]; then
    echo "Aucun backup récent trouvé" | tee -a "$LOG_FILE"
    exit 1
fi

# Transfert du fichier de sauvegarde via SCP
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$BACKUP_FILE" "$DEST_HOST:$DEST_DIR"
if [ $? -eq 0 ]; then
    MESSAGE="Succès: Sauvegarde transférée sur $DEST_HOST:$DEST_DIR"
else
    MESSAGE="Échec: Le transfert de la sauvegarde a échoué."
fi

# Enregistrer le message dans le fichier de log
echo "$MESSAGE" | tee -a "$LOG_FILE"

# Envoi du rapport par email
echo "$MESSAGE" | mail -s "Rapport de sauvegarde FreePBX" "$MAIL_RECIPIENT"