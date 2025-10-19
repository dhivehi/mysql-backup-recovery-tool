# 🗄️ MySQL Full Backup & Point-In-Time Recovery (PITR) Script

A lightweight Bash utility to perform **full MySQL backups**, **restore from dumps**, and **apply binary logs** for **point-in-time recovery (PITR)**.  
Ideal for database administrators and developers who want a simple, script-based approach to backup and recovery.

---

## 🚀 Features

- 🔹 **Full database backup** (`--all-databases`) using `mysqldump`  
- 🔹 Automatically captures **binary log position** for precise PITR  
- 🔹 Supports **restore** and **incremental replay** of binlogs  
- 🔹 Interactive CLI menu (Backup / Restore / Apply Binlogs)  
- 🔹 Configurable stop time for partial recovery (using `--stop-datetime`)  
- 🔹 Safe and non-locking backups (`--single-transaction` mode)  

---

## 🧩 Requirements

- Linux / macOS environment  
- MySQL client tools installed (`mysql`, `mysqldump`, `mysqlbinlog`)  
- Sufficient privileges for the MySQL user to perform dump and binlog read operations  

---

## ⚙️ Configuration

Edit the configuration section at the top of the script:

```bash
MYSQL_USER="myUserName"
MYSQL_PASS="myPassWord"
BACKUP_DIR="/path/to/backup/directory"
```

Optionally, set a **stop time** (UTC format) for PITR:

```bash
STOP_DATETIME="2025-10-19 12:34:00"
```

If left empty, the script replays all available logs after the last backup.

---

## 🧰 Usage

Make the script executable:

```bash
chmod +x mysql_full_backup_restore.sh
```

Then run it:

```bash
./mysql_full_backup_restore.sh
```

You’ll see an interactive menu:

```
============================================================
 MySQL Full Backup + PITR Utility
============================================================
1) Backup all databases
2) Restore from last backup
3) Apply binary logs (PITR)
4) Exit
Choose an option [1-4]:
```

---

## 💾 Backup Example

Creates a timestamped dump and binlog info:

```
🔹 Starting full MySQL backup...
✅ Backup saved to: /backups/all_databases_2025-10-19_12-00-00.sql
✅ Binlog position saved to: /backups/binlog_info_2025-10-19_12-00-00.txt
```

---

## ♻️ Restore Example

Restores databases from the last backup:

```
🔹 Restoring all databases...
✅ Databases restored from: /backups/all_databases_2025-10-19_12-00-00.sql
```

---

## 🕒 Point-in-Time Recovery Example

Applies binary logs after the last backup up to a specific time:

```
🔹 Applying binary logs for point-in-time recovery...
➡️ Using binlog file: mysql-bin.000123, position: 98765
🕒 Replaying logs until: 2025-10-19 12:34:00
✅ Point-in-time recovery completed.
```

---

## 📁 File Outputs

| File Type | Description |
|------------|--------------|
| `all_databases_<DATE>.sql` | Full MySQL dump |
| `binlog_info_<DATE>.txt` | Extracted binary log file and position |

---

## ⚠️ Notes

- Ensure binary logging (`log_bin`) is **enabled** in your MySQL configuration.  
- Test restores regularly to verify data integrity.  
- Store backups on **external storage** or a **remote server** for safety.  

---

## 🪪 License

Released under the **MIT License**.  
Feel free to use, modify, and distribute with proper attribution.
