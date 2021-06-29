#! /bin/bash

# Expected input environment variables:
# SSH_USER_HOST: user@host
# SSH_IDENTITY: path to an ssh private key to present
# BIB_SRC: path on $SSH_USER_HOST to find metadata
# DATASETS_HOME: top level path for datasets, e.g. /htprep/datasets

BIB_HOME=$DATASETS_HOME/ht_bib

/usr/bin/scp $SSH_USER_HOST:$BIB_SRC $BIB_HOME/ && /usr/bin/ssh $SSH_USER_HOST /bin/rm -f $BIB_SRC

/usr/bin/find $BIB_HOME -type f -mtime +14 -name "*jsonl.gz" -exec /bin/rm -v {} \; > /dev/null 2>&1

TODAY=$(date +"%Y%m%d")

if [[ -e $BIB_HOME/meta_ic_$TODAY.jsonl.gz ]];
then 
  ln -sfv $BIB_HOME/meta_ic_$TODAY.jsonl.gz $DATASETS_HOME/ht_text/obj/meta_ic.json.gz
fi

if [[ -e $BIB_HOME/meta_pd_google_$TODAY.jsonl.gz ]];
then 
  ln -sfv $BIB_HOME/meta_pd_google_$TODAY.jsonl.gz $DATASETS_HOME/ht_text/obj/meta_pd_google.json.gz
  ln -sfv $BIB_HOME/meta_pd_google_$TODAY.jsonl.gz $DATASETS_HOME/ht_text_pd/obj/meta_pd_google.json.gz
  ln -sfv $BIB_HOME/meta_pd_google_$TODAY.jsonl.gz $DATASETS_HOME/ht_text_pd_world/obj/meta_pd_google.json.gz
fi

if [[ -e $BIB_HOME/meta_pd_open_access_$TODAY.jsonl.gz ]];
then 
  ln -sfv $BIB_HOME/meta_pd_open_access_$TODAY.jsonl.gz $DATASETS_HOME/ht_text/obj/meta_pd_open_access.json.gz
  ln -sfv $BIB_HOME/meta_pd_open_access_$TODAY.jsonl.gz $DATASETS_HOME/ht_text_pd/obj/meta_pd_open_access.json.gz
  ln -sfv $BIB_HOME/meta_pd_open_access_$TODAY.jsonl.gz $DATASETS_HOME/ht_text_pd_world/obj/meta_pd_open_access.json.gz
  ln -sfv $BIB_HOME/meta_pd_open_access_$TODAY.jsonl.gz $DATASETS_HOME/ht_text_pd_open_access/obj/meta_pd_open_access.json.gz
  ln -sfv $BIB_HOME/meta_pd_open_access_$TODAY.jsonl.gz $DATASETS_HOME/ht_text_pd_world_open_access/obj/meta_pd_open_access.json.gz
fi
