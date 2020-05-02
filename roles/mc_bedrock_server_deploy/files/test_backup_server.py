#!/usr/bin/env python3
from datetime import datetime, timedelta
from pathlib import Path
import os
import unittest

import backup_server


class TestBackup(unittest.TestCase):
    def test_delete_stale_backup(self):
        test_backup_dir = Path('/tmp/backup_server_test/')
        daily_backup_dir = test_backup_dir / 'daily_backup/'
        weekly_backup_dir = test_backup_dir / 'weekly_backup/'
        daily_backup_dir.mkdir(parents=True, exist_ok=True)
        weekly_backup_dir.mkdir(parents=True, exist_ok=True)

        now = datetime.now()

        # Generate test files with 0-9 day(s) old.
        for i in range(10):
            i_days_old_file = daily_backup_dir / f'{i}_days_old_file.tar.gz'
            i_days_old_file.touch()
            i_days_old_timestamp = (now - timedelta(days=i)).timestamp()
            os.utime(i_days_old_file,
                     (i_days_old_timestamp, i_days_old_timestamp))

        # Generate test files with 0-5 week(s) old.
        for i in range(6):
            days = i * 7
            i_weeks_old_file = weekly_backup_dir / f'{i}_weeks_old_file.tar.gz'
            i_weeks_old_file.touch()
            i_weeks_old_timestamp = (now - timedelta(days=days)).timestamp()
            os.utime(i_weeks_old_file,
                     (i_weeks_old_timestamp, i_weeks_old_timestamp))

        # Test if the script successfully remove stale backup
        backup_server.remove_stale_backup(test_backup_dir)
        daily_backup_files = list(daily_backup_dir.glob('*'))
        weekly_backup_files = list(weekly_backup_dir.glob('*'))
        self.assertNotIn(daily_backup_dir / '7_days_old_file',
                         daily_backup_files)
        self.assertNotIn(weekly_backup_dir / '4_weeks_old_file',
                         weekly_backup_files)


if __name__ == "__main__":
    unittest.main()
