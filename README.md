[![Tests](https://github.com/hathitrust/datasets/actions/workflows/ci.yml/badge.svg)](https://github.com/hathitrust/datasets/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/hathitrust/datasets/badge.svg?branch=main)](https://coveralls.io/github/hathitrust/datasets?branch=main)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

# HathiTrust Datasets Builder
This project maintains the full text datasets provided to researchers and the HathiTrust Research Center.

## Development

```bash
git clone https://github.com/hathitrust/datasets
cd datasets
docker-compose build
docker-compose run test bundle install
docker-compose run test
```

## Datasets Design

### Volumes
The datasets are the volume fulltexts with rights that permit inclusion in and distribution by the hathitrust research datasets. Each volume is uniquely identified by a prefix and number. e.g. pre.01234567891011 or exp.11223344556677

### Superset (ht_text)
The entire corpus of the fulltexts available for research is called `ht_text`.  This is the superset of available volumes. This set is only used directly by the HathiTrust Research Center. 

### Subsets
There are subsets of volumes that correspond to specific rights attributed to the volumes.  For example, volumes with the rights, public domain world, are in the subset ht_text_pd_world. The list of subsets is:  
- ht_text_pd
- ht_text_pd_open_access
- ht_text_pd_world
- ht_text_pd_world_open_access

### Content and Symlinks
The The zip files which contain the data reside in ht_text (the superset). The subsets are mirrors of sections of the ht_text pairtree with the final directory being a symlink to the correpsonding directory in ht_text.
```
ls -l /datasets/ht_text_pd_world/obj/exp/pairtree_root/11/22/33/44/55/66/77
11223344556677 -> /datasets/ht_text/ht_text_pd_world/obj/exp/pairtree_root/11/22/33/44/55/66/77
```

## Operation
1. ### Queue Check
Prior to beginning a new run, the queue of jobs must be empty.  In order to be empty, each job must have completed successfully.  Failed jobs are re-queued.  This is done to prevent race conditions with multiple changes to the same volume.

1. ### Get Changes
There are two kinds of changes to the HathiTrust volumes that the research datasets need to incorporate:
    - *Rights*: Updates to the copyright determination or access rights.  Queried from the aptly named, rights table.
    - *Content*: Updates to the OCR text.  Queried from the re-ingest feed table.

1. ### Filter Changes
The list of changes is filtered into queues.  There is a queue for each subset and a queue for the content changes.

1. ### Schedule Jobs
For each volume in a queue, a job is scheduled to apply the changes to the filesystem.

## Use
Scheduled job to be run daily? weekly?

## Assumptions & Dependencies
Atomic filesystem moves.  This remains to be tested.

