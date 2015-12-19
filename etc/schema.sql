CREATE TABLE `dataset_tracking` (
  `namespace` varchar(8) NOT NULL DEFAULT '',
  `id` varchar(32) NOT NULL DEFAULT '',
  `zip_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'zip_date in repository',
  `pd_us` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'item is in pd sets',
  `pd_world` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'item is in pd world sets',
  `open_access` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'item is in open access sets',
  PRIMARY KEY (`namespace`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Each item in this table is in the HT dataset. Presence indicates that it is there, not that it should be.'

CREATE TABLE `dataset_deletes` (
  `namespace` varchar(8) NOT NULL DEFAULT '',
  `id` varchar(32) NOT NULL DEFAULT '',
  `in_copyright` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Copy deleted from in copyright dataset',
  `pd_us` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Link deleted from pd us datasets',
  `pd_world` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Link deleted from pd world datasets',
  `open_access` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Link deleted from open access datasets',
  `world_open_access` tinyint(1) DEFAULT '0' COMMENT 'Link deleted from the world open access dataset',
  `urgent` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Send notification within 24 hours',
  PRIMARY KEY (`namespace`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Items recently removed from datasets. Rows purged once notifications are sent.'
