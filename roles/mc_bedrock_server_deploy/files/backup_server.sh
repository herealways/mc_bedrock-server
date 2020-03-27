#!/bin/bash
backup_dir="$1"

today=$(date +%F)
exec &>> "$backup_dir"/backup_log

# Checking if the mc bedrock server is running. If it is not running, don't backup
docker ps | grep bedrock-server &>/dev/null
if [ $? = 0 ]
then
    echo -e "\n[$(date +%F-%T)]Stopping the server before backup..."
    docker stop bedrock-server &>/dev/null
else
    echo -e "\n[$(date +%F-%T)]The server is not running, exiting..."
    exit 0
fi

# Starting daily backup
echo "[$(date +%F-%T)]Starting daily backup..."
docker run --rm --volumes-from bedrock-server -v "$backup_dir"/daily_backup:/backup \
ubuntu:18.04 bash -c "tar czf /backup/$(date +%F)_world_backup.tar.gz \
/bedrock-server/{permissions.json,server.properties,whitelist.json,worlds}" &>/dev/null \
&& echo "[$(date +%F-%T)]Daily backup Completed!" || echo "[$(date +%F-%T)]Daily backup failed!"

# Starting weekly full backup on Friday
if [ $(date +%u) = 5 ]
then
    echo "[$(date +%F-%T)]Starting weekly backup..."
    docker run --rm --volumes-from bedrock-server -v "$backup_dir"/weekly_backup:/backup \
    ubuntu:18.04 bash -c "tar czf /backup/$(date +%F)_full_backup.tar.gz \
    /bedrock-server" &>/dev/null \
    && echo "[$(date +%F-%T)]Weekly backup Completed!" || echo "[$(date +%F-%T)]Weekly backup failed!"
fi
# Restarting stopped mc bedrock server
echo -e "[$(date +%F-%T)]Restarting the server..."
docker start bedrock-server &>/dev/null

# Delete old daily backup files
find "$backup_dir"/daily_backup -type f -name "*_world_backup.tar.gz" -mtime +6 -delete

# Delete old weekly backup files
find "$backup_dir"/weekly_backup -type f -name "*_full_backup.tar.gz" -mtime +27 -delete
