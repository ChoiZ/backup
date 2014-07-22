Backup
======

## Folder

### Documentation

1.  Edit `EMAIL` and `FOLDER` variables.
2.  Backup.

Backup `/var/www` into `/backup/www`:

    ./backup.sh web_backup /var/www /backup/www

Backup `/var/www` into `/backup/www` and email the result at backup@domain.com:

    ./backup.sh web_backup /var/www /backup/www backup@domain.com

### Log

Success:

    [2014-07-22 00h24:00] Backup `web_backup`…
    Number of files: 3
    Number of files transferred: 2
    Total file size: 0 bytes
    Total transferred file size: 0 bytes
    Literal data: 0 bytes
    Matched data: 0 bytes
    File list size: 49
    File list generation time: 0.001 seconds
    File list transfer time: 0.000 seconds
    Total bytes sent: 133
    Total bytes received: 53
    sent 133 bytes  received 53 bytes  372.00 bytes/sec
    total size is 0  speedup is 0.00
    [2014-07-22 00h24:00] Backup `web_backup` [success]

Failed:

    [2014-07-22 12h43:04] Backup `web_failed`…
    rsync: link_stat "/backup/source" failed: No such file or directory (2)
    --link-dest arg does not exist: /backup/web_failed/current
    Number of files: 0
    Number of files transferred: 0
    Total file size: 0 bytes
    Total transferred file size: 0 bytes
    Literal data: 0 bytes
    Matched data: 0 bytes
    File list size: 3
    File list generation time: 0.001 seconds
    File list transfer time: 0.000 seconds
    Total bytes sent: 12
    Total bytes received: 12
    sent 12 bytes  received 12 bytes  48.00 bytes/sec
    total size is 0  speedup is 0.00
    rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1070) [sender=3.0.9]
    [2014-07-22 12h43:04] Backup `web_failed` [failed]

## MySQL

### Documentation

1.  Create your `backup` user in MySQL.
2.  Edit `EMAIL`, `FOLDER`, `SQL_LOGIN` and `SQL_PASS` variables.
3.  Backup

Backup `success` database:

    ./backup_sql.sh success

Backup `failed` database and send email to backup@domain.com:

    ./backup_sql.sh failed backup@domain.com

### Log

Success:

    [2014-07-22 00h53:33] Backup MySQL database `success`…
    [2014-07-22 00h53:33] Backup MySQL database `success` [success]

Failed:

    [2014-07-22 00h53:43] Backup MySQL database `failed`…
    ERROR 1049 (42000): Unknown database 'failed'
    [2014-07-22 00h53:43] Backup MySQL database `failed` [failed]
