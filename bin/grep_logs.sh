#!/bin/bash

DATE=$(date -d "yesterday 13:00" '+%Y%m%d')
LOGDIR=/htprep/datasets/logs
DELETELOG=$LOGDIR/deletelog_$DATE.txt
FULL_SET_LOGS=/htprep/datasets/ht_text/obj/ingest_log
egrep 'profile: (force_)?full,.*: updated$' $LOGDIR/*-$DATE.log | perl -pi -e 's/.*volume: (\S+) .*/$1/' > $FULL_SET_LOGS/full_set_updates_$DATE.txt

egrep ': removed$' $LOGDIR/*-$DATE.log | perl -pi -e 's/.*profile: (\S+), volume: (\S+) .*/$1\t$2/' > $DELETELOG

egrep '^full	' $DELETELOG | cut -f 2 > $FULL_SET_LOGS/full_set_deletes_$DATE.txt
# egrep '^pd	' $DELETELOG > $LOGDIR/pd_deletes_$DATE.txt && echo 'email to ht-dataset-pd@umich.edu'
# egrep '^pd_open	' $DELETELOG > $LOGDIR/pd_open_access_deletes_$DATE.txt && echo 'email to ht-dataset-pd-oa@umich.edu'
# egrep '^pd_world	' $DELETELOG > $LOGDIR/pd_world_deletes.$DATE.txt && echo 'email to ht-dataset-pd-world@umich.edu'
# egrep '^pd_world_open	' $DELETELOG > $LOGDIR/pd_world_open_deletes_$DATE.txt && echo 'email to ht-dataset-pd-world-oa@umich.edu'

# concat & compress logs
cat $LOGDIR/*-$DATE.log | bzip2 -9 > $LOGDIR/dataset-$DATE.log.bz2 && rm $LOGDIR/*-$DATE.log

# email deletes; move delete log to 'sent' if success
/htapps/babel/datasets/bin/notify.rb $LOGDIR/deletelog* && mv $LOGDIR/deletelog* $LOGDIR/delete_notifications_sent/
