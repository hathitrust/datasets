#!/bin/bash

# Expected input environment variables:
# DATASETS_HOME: top level path for datasets, e.g. /htprep/datasets

stamp=$(date +\%Y\%m\%d) && find $DATASETS_HOME/ht_text/obj/ -type f -print | gzip > $DATASETS_HOME/ht_text/obj/manifests/ht_text_manifest_${stamp}.txt.gz 2> $DATASETS_HOME/ht_text/obj/manifests/ht_text_manifest_${stamp}.err
