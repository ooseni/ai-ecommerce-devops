#!/usr/bin/env bash
# backup.sh: dump the shop's MongoDB database to a compressed archive.
# Writes backups/<db>-YYYYMMDD-HHMMSS.archive.gz, readable only by you,
# and keeps the newest KEEP archives (default 7).
#
# Usage: scripts/backup.sh
# Restore: docker exec -i mongo-dev mongorestore --archive --gzip --drop < backups/<file>

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$ROOT/backups}"
MONGO_CONTAINER="${MONGO_CONTAINER:-mongo-dev}"
DB_NAME="${DB_NAME:-mern_ecommerce}"
KEEP="${KEEP:-7}"

[[ "$KEEP" =~ ^[1-9][0-9]*$ ]] || {
  echo "KEEP must be a whole number of 1 or more" >&2
  exit 1
}

if [[ "$(docker inspect -f '{{.State.Running}}' "$MONGO_CONTAINER" 2>/dev/null)" != "true" ]]; then
  echo "$MONGO_CONTAINER is not running, start it with scripts/setup.sh" >&2
  exit 1
fi

# mongodump exits 0 for a database that doesn't exist, so check first
# instead of saving an empty backup.
collections=$(docker exec "$MONGO_CONTAINER" mongosh --quiet --eval \
  "db.getSiblingDB('$DB_NAME').getCollectionNames().length")
if ((collections == 0)); then
  echo "database $DB_NAME has no collections, nothing to back up" >&2
  exit 1
fi

# Dumps hold user emails and password hashes: owner-only folder and files.
umask 077
mkdir -p "$BACKUP_DIR"

file="$BACKUP_DIR/$DB_NAME-$(date +%Y%m%d-%H%M%S).archive.gz"
part="$file.part"
trap 'rm -f "$part"' EXIT

# Write to .part and rename only once the dump is complete and valid,
# so a failed run never leaves a broken file that looks like a backup.
docker exec "$MONGO_CONTAINER" mongodump --quiet --db "$DB_NAME" --archive --gzip >"$part"
gzip -t "$part"
mv "$part" "$file"
echo "Backup written: ${file#"$ROOT"/} ($(du -h "$file" | cut -f1), $collections collections)"

# Keep the newest KEEP archives. The glob sorts by name, and the fixed-width
# timestamp makes name order the same as time order, oldest first.
shopt -s nullglob
archives=("$BACKUP_DIR/$DB_NAME"-*.archive.gz)
count=${#archives[@]}
if ((count > KEEP)); then
  for old in "${archives[@]:0:count-KEEP}"; do
    rm -f "$old"
    echo "Removed old backup: ${old##*/}"
  done
  count=$KEEP
fi
echo "Backups kept: $count (limit $KEEP)"
