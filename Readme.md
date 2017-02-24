# HathiTrust Datasets Builder
This project maintains the full text datasets provided to researchers and the HathiTrust Research Center.

## Datasets Design
The datasets are the volume fulltexts with rights that permit inclusion in and distribution by the hathitrust research datasets. Each volume is uniquely identified by a prefix and number. e.g. pre.01234567891011 or exp.11223344556677

The entire corpus of the fulltexts available for research is called `ht_text`.  This is the superset of available volumes. This set is only used directly by the HathiTrust Research Center. 

There are subsets of volumes that correspond to specific rights attributed to the volumes.  For example, volumes with the rights, public domain world, are in the subset ht_text_pd_world. The list of subsets is:  
- ht_text_pd
- ht_text_pd_open_access
- ht_text_pd_world
- ht_text_pd_world_open_access


The The zip files which contain the data reside in ht_text (the superset). The subsets are mirrors of sections of the ht_text pairtree with the final directory being a symlink to the correpsonding directory in ht_text.
```
ls -l /datasets/ht_text_pd_world/obj/exp/pairtree_root/11/22/33/44/55/66/77
11223344556677 -> /datasets/ht_text/ht_text_pd_world/obj/exp/pairtree_root/11/22/33/44/55/66/77
```

## Operation

## Use

## Assumptions & Dependencies

