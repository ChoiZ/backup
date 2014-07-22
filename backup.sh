#!/bin/bash
# Incremental backup script
# Last modified: 2014-07-22
# Author: François LASSERRE <choiz@me.com>
# Forked from: https://github.com/thebestsolution/backup-script
# License: GNU GPL http://www.gnu.org/licenses/gpl.html

EMAIL=""
FOLDER="/backup"
HOST=`hostname`

DATE=`date +%F` # Full Date (e.g. 2012-12-31)
DAY_OF_WEEK=`date +%w` # Day of week. (1 for Monday…)
DAY_OF_MONTH=`date +%d` # Day of Month (e.g. 31)
TIME=`date +%Hh%M:%S` # Full Time (e.g. 13h11:58)

# Backup name
if [ -n "$1" ]; then
    NAME=$1 # Name of backup
else
    exit 1
fi

# Backup Source
if [ -n "$2" ]; then
    SRC=$2
else
    exit 1
fi

# Backup Destination
if [ -n "$3" ]; then
    DEST=$3
else
    DEST="$FOLDER/web/$NAME"
fi

# Email
if [ -n "$4" ]; then
    EMAIL=$4
fi

LOG="$FOLDER/logs/web_$NAME.log"

function create_folder() {

    # Create current directory
    if [ ! -d "$DEST/current" ]; then
        mkdir -p $DEST/current
    fi

    if [ -d "$DEST/incomplete" ]; then
        rm -rf $DEST/incomplete
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
        DATE_DEST=$DEST/daily/`date +%F`
    fi

}

function backup_folder() {

    FOLDER_BACKUP=$1

    echo "[$DATE $TIME] $HOST Backup \`$FOLDER_BACKUP\`…" > $LOG

    create_folder

    # Execute the rsync task
    rsync -az --numeric-ids --stats --human-readable --delete --link-dest=$DEST/current $SRC $DEST/incomplete >> $LOG 2>&1 && BACKUP_SUCCESS=1 || BACKUP_SUCCESS=0

    # Delete existing destination directory
    if [ -d "$DATE_DEST" ]; then
        rm -rf $DATE_DEST
    fi

    # Move backup to destination and setup new reference directory
    mv $DEST/incomplete $DATE_DEST
    rm -rf $DEST/current && ln -s $DATE_DEST $DEST/current

    if [ $BACKUP_SUCCESS = "1" ]; then
        echo "[$DATE $TIME] $HOST Backup \`$FOLDER_BACKUP\` [success]" >> $LOG
        if [ -n "$EMAIL" ]; then
            cat $LOG | mail -s "$HOST Backup \`$FOLDER_BACKUP\`: success" $EMAIL
        fi
    else
        echo "[$DATE $TIME] $HOST Backup \`$FOLDER_BACKUP\` [failed]" >> $LOG
        if [ -n "$EMAIL" ]; then
            cat $LOG | mail -s "$HOST Backup \`$FOLDER_BACKUP\`: failed" $EMAIL
        fi
    fi

}

backup_folder $NAME