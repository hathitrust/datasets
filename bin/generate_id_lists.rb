#!/bin/bash

=begin >/dev/null 2>&1
source "$(dirname $0)/../lib/ruby.sh"
require '2.2'
ruby.sh
=end

#!ruby

# generate_id_lists.rb
# generate id list for each subset

require_relative '../lib/database.rb'
require_relative '../lib/config.rb'

dataset_path = HTConfig.config['dataset_path']

def write_id_list(path,items)
  open("#{path}/id", mode='w') do |f|
    items.each do |item|
      f.puts "#{item[:namespace]}.#{item[:id]}"
    end
  end
  system "cd #{path}; zip 'id.zip' 'id' > /dev/null; rm -f 'id'"
end

write_id_list("#{dataset_path}/obj"                      , HTDB.items(subset: 'ht_text') )
write_id_list("#{dataset_path}_pd/obj"                   , HTDB.items(subset: 'ht_text_pd') )
write_id_list("#{dataset_path}_pd_open_access/obj"       , HTDB.items(subset: 'ht_text_pd_open_access') )
write_id_list("#{dataset_path}_pd_world/obj"             , HTDB.items(subset: 'ht_text_pd_world') )
write_id_list("#{dataset_path}_pd_world_open_access/obj" , HTDB.items(subset: 'ht_text_pd_world_open_access') )
