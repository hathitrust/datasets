# info.rb
# print some information about current datasets

require_relative '../lib/config.rb'
require_relative '../lib/database.rb'

db = HTDB.get

info = <<DOC
Total items in datasets: #{HTDB.items.count}

Items in subsets:
\tht_text_pd:                  #{HTDB.items(subset: 'ht_text_pd').count}
\tht_text_pd_openaccess:       #{HTDB.items(subset: 'ht_text_pd_open_access').count}
\tht_text_pd_world:            #{HTDB.items(subset: 'ht_text_pd_world').count}
\tht_text_pd_world_openaccess: #{HTDB.items(subset: 'ht_text_pd_world_open_access').count}

Pending delete notifications:
\tAll:    #{HTDB.notifications.count}
\tUrgent: #{HTDB.notifications(urgent_only: true).count}

DOC

puts info
