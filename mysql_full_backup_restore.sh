#!/bin/bash
# ============================================================
# MySQL Full Backup + Point-in-Time Recovery (PITR)
# ============================================================
# Make this file executable by running: chmod +x ./mysql_full_backup_restore.sh

# ---- CONFIGURATION ----
MYSQL_USER="myUserName"
MYSQL_PASS="myPassWord"
BACKUP_DIR="/path/to/backup/directory"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/all_databases_${DATE}.sql"
BINLOG_INFO_FILE="${BACKUP_DIR}/binlog_info_${DATE}.txt"
STOP_DATETIME=""  # e.g. "2025-10-19 12:34:00" (leave empty for full recovery)

# ---- FUNCTIONS ----
backup_all_databases() {
    echo "🔹 Starting full MySQL backup..."
    mkdir -p "$BACKUP_DIR"

    mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASS" \
        --all-databases \
        --source-data=2 \
        --single-transaction \
        --quick \
        --lock-tables=false \
        > "$BACKUP_FILE"

    echo "✅ Backup saved to: $BACKUP_FILE"

    # Extract binlog info
    grep -m 1 "CHANGE MASTER TO" "$BACKUP_FILE" > "$BINLOG_INFO_FILE"
    echo "✅ Binlog position saved to: $BINLOG_INFO_FILE"
    cat "$BINLOG_INFO_FILE"
}

restore_all_databases() {
    echo "🔹 Restoring all databases..."
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" < "$BACKUP_FILE"
    echo "✅ Databases restored from: $BACKUP_FILE"
}

apply_binlogs() {
    echo "🔹 Applying binary logs for point-in-time recovery..."

    # Extract values
    BINLOG_FILE=$(grep -oP "MASTER_LOG_FILE='\K[^']+" "$BINLOG_INFO_FILE")
    BINLOG_POS=$(grep -oP "MASTER_LOG_POS=\K[0-9]+" "$BINLOG_INFO_FILE")

    if [[ -z "$BINLOG_FILE" || -z "$BINLOG_POS" ]]; then
        echo "❌ Could not extract binlog info. Check $BINLOG_INFO_FILE"
        exit 1
    fi

    echo "➡️ Using binlog file: $BINLOG_FILE, position: $BINLOG_POS"

    if [[ -n "$STOP_DATETIME" ]]; then
        echo "🕒 Replaying logs until: $STOP_DATETIME"
        mysqlbinlog --start-position="$BINLOG_POS" \
            --stop-datetime="$STOP_DATETIME" \
            /var/lib/mysql/"$BINLOG_FILE" | mysql -u"$MYSQL_USER" -p"$MYSQL_PASS"
    else
        echo "🕒 Replaying all logs after backup position..."
        mysqlbinlog --start-position="$BINLOG_POS" \
            /var/lib/mysql/"$BINLOG_FILE" | mysql -u"$MYSQL_USER" -p"$MYSQL_PASS"
    fi

    echo "✅ Point-in-time recovery completed."
}

# ---- MAIN LOGIC ----
echo "============================================================"
echo " MySQL Full Backup + PITR Utility"
echo "============================================================"
echo "1) Backup all databases"
echo "2) Restore from last backup"
echo "3) Apply binary logs (PITR)"
echo "4) Exit"
read -rp "Choose an option [1-4]: " choice

case "$choice" in
    1) backup_all_databases ;;
    2) restore_all_databases ;;
    3) apply_binlogs ;;
    4) exit 0 ;;
    *) echo "Invalid choice!" ;;
esac
