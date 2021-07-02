#!/bin/bash

set -x

DATE=$(date -d "yesterday 13:00" '+%Y%m%d')
LOGDIR=/htprep/datasets/logs
DELETELOG=$LOGDIR/deletelog_$DATE.txt
SENT_DELETELOG=$LOGDIR/delete_notifications_sent/deletelog_$DATE.txt
COMBINED_LOG=$LOGDIR/dataset-$DATE.log.bz2
FULL_SET_LOGS=/htprep/datasets/ht_text/obj/ingest_log
FULL_SET_UPDATES=$FULL_SET_LOGS/full_set_updates_$DATE.txt
FULL_SET_DELETES=$FULL_SET_LOGS/full_set_deletes_$DATE.txt

if [[ ! -e $FULL_SET_UPDATES ]]; then
  egrep 'profile: (force_)?full,.*: updated$' $LOGDIR/*-$DATE.log | perl -pi -e 's/.*volume: (\S+) .*/$1/' > $FULL_SET_UPDATES
fi

if [[ ! -e $DELETELOG && ! -e $SENT_DELETELOG ]]; then
  egrep ': removed$' $LOGDIR/*-$DATE.log | perl -pi -e 's/.*profile: (\S+), volume: (\S+) .*/$1\t$2/' > $DELETELOG
fi

if [[ ! -e $FULL_SET_DELETES ]]; then
  egrep '^full	' $DELETELOG | cut -f 2 > $FULL_SET_DELETES
fi

if [[ ! -e $COMBINED_LOG ]]; then
  # concat & compress logs
  cat $LOGDIR/*-$DATE.log | bzip2 -9 > $COMBINED_LOG && rm $LOGDIR/*-$DATE.log
fi

# email deletes; move delete log to 'sent' if success
/usr/src/app/bin/notify.rb $LOGDIR/deletelog* && mv $LOGDIR/deletelog* $LOGDIR/delete_notifications_sent/
