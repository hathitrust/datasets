#!/bin/bash

set -x

LOGDIR=/htprep/datasets/logs
if compgen -G "$LOGDIR/deletelog*" > /dev/null; then
  # email deletes; move delete log to 'sent' if success
  /usr/src/app/bin/datasets.rb notify --smtp-host $SMTP_HOST $LOGDIR/deletelog* && mv $LOGDIR/deletelog* $LOGDIR/delete_notifications_sent/
fi
