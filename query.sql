/* ht_text                    */
SELECT namespace,id FROM rights_current WHERE access_profile IN (1,2) AND attr NOT IN (8,26); /*AND reason NOT IN (6,16)*/
SELECT namespace,id FROM rights_current WHERE access_profile IN (1,2) AND attr NOT IN (8,26) LIMIT 0,7000000;
SELECT namespace,id FROM rights_current WHERE access_profile IN (1,2) AND attr NOT IN (8,26) LIMIT 7000000,7000000;
/* ht_text_pd                 */
SELECT namespace,id FROM rights_current WHERE access_profile IN (1,2) AND attr IN (1,7,9,10,11,12,13,14,15,17,20,21,22,23,24,25);
/* ht_text_pd_open_access     */
SELECT namespace,id FROM rights_current WHERE access_profile IN (1)   AND attr IN (1,7,9,10,11,12,13,14,15,17,20,21,22,23,24,25);
/* ht_text_pd_world           */
SELECT namespace,id FROM rights_current WHERE access_profile IN (1,2) AND attr IN (1,7,10,11,12,13,14,15,17,20,21,22,23,24,25);
/*ht_text_pd_world_open_access*/
SELECT namespace,id FROM rights_current WHERE access_profile IN (1)   AND attr IN (1,7,10,11,12,13,14,15,17,20,21,22,23,24,25);
