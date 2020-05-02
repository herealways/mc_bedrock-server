#!/usr/bin/env python3
from datetime import datetime
import logging
from pathlib import Path
import sys
import subprocess as sub


def check_game_running():
    p = sub.run('docker ps | grep bedrock-server', shell=True,
                stdout=sub.DEVNULL, stderr=sub.DEVNULL)
    if p.returncode != 0:
        logging.info('The server is not running and backup will not be\
performed')
        sys.exit(1)
    logging.debug('Stopping the server before backup...')
    sub.run('docker stop bedrock-server', shell=True,
            stdout=sub.DEVNULL, stderr=sub.DEVNULL)


def daily_backup(backup_dir):
    logging.debug('Starting daily backup...')
    command = f'docker run --rm --volumes-from bedrock-server \
-v {backup_dir}/daily_backup:/backup \
ubuntu:18.04 bash -c "tar czf /backup/$(date +%F)_world_backup.tar.gz \
/bedrock-server/{{permissions.json,server.properties,whitelist.json,worlds}}"'

    p = sub.run(command, shell=True, stdout=sub.DEVNULL, stderr=sub.DEVNULL)
    if p.returncode != 0:
        logging.error('Daily backup failed somehow!')
    else:
        logging.info('Daily backup succeeded.')


def weekly_backup(backup_dir):
    # Only performing weekly backup on Friday.
    if datetime.now().strftime('%u') != '5':
        return

    command = f'docker run --rm --volumes-from bedrock-server \
-v {backup_dir}/weekly_backup:/backup \
ubuntu:18.04 bash -c "tar czf /backup/$(date +%F)_full_backup.tar.gz \
/bedrock-server"'

    p = sub.run(command, shell=True, stdout=sub.DEVNULL, stderr=sub.DEVNULL)
    if p.returncode != 0:
        logging.error('Weekly backup failed somehow!')
    else:
        logging.info('Weekly backup succeeded.')


def restart_server():
    sub.run('docker start bedrock-server', shell=True,
            stderr=sub.DEVNULL, stdout=sub.DEVNULL)


def remove_stale_backup(backup_dir):
    daily_backup_dir = backup_dir / 'daily_backup/'
    weekly_backup_dir = backup_dir / 'weekly_backup/'

    daily_backup_files = list(daily_backup_dir.glob('*.tar.gz'))
    weekly_backup_files = list(weekly_backup_dir.glob('*.tar.gz'))

    now = datetime.now()

    # Delete daily backup files that are older than 7 days
    for f in daily_backup_files:
        if (now - datetime.fromtimestamp(f.stat().st_mtime)).days > 6:
            f.unlink()

    # Delete weekly backup files that are older than 4 weeks
    for f in weekly_backup_files:
        if (now - datetime.fromtimestamp(f.stat().st_mtime)).days > 27:
            f.unlink()


if __name__ == "__main__":
    backup_dir = Path(sys.argv[1])
    log_file = backup_dir / 'backup_log'
    logging.basicConfig(level=logging.INFO, filename=log_file,
                        format='%(asctime)s - %(message)s')

    check_game_running()
    daily_backup(backup_dir)
    weekly_backup(backup_dir)
    restart_server()
    remove_stale_backup(backup_dir)
