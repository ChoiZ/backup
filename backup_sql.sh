#!/bin/bash
# Backup SQL
# Last modified: 2014-08-20
# Author: François LASSERRE <choiz@me.com>
# License: GNU GPL http://www.gnu.org/licenses/gpl.html

#
# mysqldump --single-transaction (InnoDB)
# CREATE USER 'backup'@'localhost' IDENTIFIED BY 'secret';
# GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup'@'localhost';
#
# mysqldump --lock-all-tables (MyISAM)
# GRANT LOCK TABLES ON *.* TO 'backup'@'localhost';
#

EMAIL=""
FOLDER="/backup"
HOST=`hostname`

SQL_LOGIN=""
SQL_PASS=""

DATE=`date +%F` # Full Date (e.g. 2012-12-31)
DAY_OF_WEEK=`date +%w` # Day of week. (1 for Monday…)
DAY_OF_MONTH=`date +%d` # Day of Month (e.g. 31)

TIME=`date +%Hh%M:%S` # Full Time (e.g. 13h11:58)
TIME_H_M=`date +%Hh%M` # Time (e.g. 13h11)

MAX_DISK_USED=80 # Max disk use in percent.
DISK_USED=`df -P $FOLDER | awk '{print $5}' | grep % | cut -d% -f1`

if [ $DISK_USED -ge $MAX_DISK_USED ]; then
    echo "$FOLDER disk usage is above $MAX_DISK_USED%. Aborting backup.";
    exit 1
fi

# Backup name
if [ -n "$1" ]; then
    DATABASE=$1 # Name of backup
    DEST="$FOLDER/sql/$DATABASE"
else
    exit 1
fi

# Email
if [ -n "$2" ]; then
    EMAIL=$2
fi

function create_folder() {

    # Create current directory
    if [ ! -d "$DEST/current" ]; then
        mkdir -p $DEST/current
    fi

    if [ ! -d "$DEST/logs" ]; then
        mkdir -p $DEST/logs
    fi

    LOG=$DEST/logs/$DATABASE-$DATE-$TIME_H_M.log

    if [ -d "$DEST/incomplete" ]; then
        rm -rf $DEST/incomplete
    fi

    # Create incomplete directory
    if [ ! -d "$DEST/incomplete" ]; then
        mkdir -p $DEST/incomplete
    fi

    # Monthly full backup monthly/2014-07
    if [ $DAY_OF_MONTH = "01" ]; then
        if [ ! -d "$DEST/monthly" ]; then
            mkdir $DEST/monthly
        fi
        DATE_DEST=$DEST/monthly/`date +%Y-%m`
    # Weekly full backup weekly/2014-
    elif [ $DAY_OF_WEEK = "5" ]; then
        if [ ! -d "$DEST/weekly" ]; then
            mkdir $DEST/weekly
        fi
        DATE_DEST=$DEST/weekly/$DATE
    # Make incremental backup - overwrite last weeks
    else
        if [ ! -d "$DEST/daily" ]; then
            mkdir $DEST/daily
        fi
        DATE_DEST=$DEST/daily/$DATE
    fi

}

function sql_backup() {

    FILENAME="$DATABASE-$DATE-$TIME_H_M"

    echo "[$DATE $TIME] $HOST Backup MySQL database \`$DATABASE\`…" > $LOG

    create_folder

    mysqldump -u $SQL_LOGIN -p$SQL_PASS $DATABASE > $DEST/incomplete/$FILENAME.sql 2>&1 && BACKUP_SUCCESS="1" || mysql -u $SQL_LOGIN -p$SQL_PASS $DATABASE >> $LOG 2>&1 || BACKUP_SUCCESS="0"

    # Delete existing destination directory
    if [ -d "$DATE_DEST" ]; then
        rm -rf $DATE_DEST
    fi

    # Move backup to destination and setup new reference directory
    mv $DEST/incomplete $DATE_DEST
    rm -rf $DEST/current && ln -s $DATE_DEST $DEST/current

    if [ $BACKUP_SUCCESS = "1" ]; then
        echo "[$DATE $TIME] $HOST Backup MySQL database \`$DATABASE\` [success]" >> $LOG
        if [ -n "$EMAIL" ]; then
            cat $LOG | mail -s "$HOST Backup \`$DATABASE\`: success" $EMAIL
        fi
    else
        echo "[$DATE $TIME] $HOST Backup MySQL database \`$DATABASE\` [failed]" >> $LOG
        if [ -n "$EMAIL" ]; then
            cat $LOG | mail -s "$HOST Backup \`$DATABASE\`: failed" $EMAIL
        fi
    fi

}

sql_backup
