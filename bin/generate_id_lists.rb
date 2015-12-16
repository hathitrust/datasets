# generate_id_lists.rb
# generate id list for each subset

require_relative '../lib/database.rb'
require_relative '../lib/config.rb'

dataset_path = HTConfig.config['dataset_path']

def write_id_list(path,items)
  open(path, mode='w') do |f|
    items.each do |item|
      f.puts "#{item[:namespace]}.#{item[:id]}"
    end
  end
end

write_id_list("#{dataset_path}/obj/id"                      , HTDB.items(subset: 'ht_text') )
write_id_list("#{dataset_path}_pd/obj/id"                   , HTDB.items(subset: 'ht_text_pd') )
write_id_list("#{dataset_path}_pd_open_access/obj/id"       , HTDB.items(subset: 'ht_text_pd_open_access') )
write_id_list("#{dataset_path}_pd_world/obj/id"             , HTDB.items(subset: 'ht_text_pd_world') )
write_id_list("#{dataset_path}_pd_world_open_access/obj/id" , HTDB.items(subset: 'ht_text_pd_world_open_access') )
