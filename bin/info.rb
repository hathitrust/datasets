#!/bin/bash

=begin >/dev/null 2>&1
source "$(dirname $0)/../lib/ruby.sh"
require '2.2'
ruby.sh
=end

#!ruby

# info.rb
# print some information about current datasets

require_relative '../lib/config.rb'
require_relative '../lib/database.rb'
dataset_path = HTConfig.config['dataset_path']

puts "Total items in datasets: #{HTDB.items.count}"
puts ""
puts "Items in subsets:"
puts "\tht_text_pd:                   #{sprintf('%8d',HTDB.items(subset: 'ht_text_pd').count)}"
puts "\tht_text_pd_open_access:       #{sprintf('%8d',HTDB.items(subset: 'ht_text_pd_open_access').count)}"
puts "\tht_text_pd_world:             #{sprintf('%8d',HTDB.items(subset: 'ht_text_pd_world').count)}"
puts "\tht_text_pd_world_open_access: #{sprintf('%8d',HTDB.items(subset: 'ht_text_pd_world_open_access').count)}"
puts ""
puts "Pending delete notifications:"
puts "\tAll:    #{sprintf('%4d',HTDB.notifications.count)}"
puts "\tUrgent: #{sprintf('%4d',HTDB.notifications(urgent_only: true).count)}"
puts ""
puts "Pending deletes:"
puts "\tItems to delete from all sets:         #{sprintf('%4d',HTDB.items_to_delete.count)}"
puts "\tItems to remove from pd sets:          #{sprintf('%4d',HTDB.items_to_delink_from_all.count)}"
puts "\tItems to remove from pd_world sets:    #{sprintf('%4d',HTDB.items_to_delink_from_world.count)}"
puts "\tItems to remove from open_access sets: #{sprintf('%4d',HTDB.items_to_delink_from_open_access.count)}"
puts ""
puts "Items to ingest (estimate, always high): #{sprintf('%7d',HTDB.items_to_ingest.count)}"
puts "Items to reingest:                       #{sprintf('%7d',HTDB.items_to_reingest.count)}"
puts "Items to link:                           #{sprintf('%7d',HTDB.items_to_link.count)}"
if(DEBUG)
  puts ""
  puts "Filesystem:"
  puts dataset_path
  puts "#{dataset_path}_pd"
  puts "#{dataset_path}_pd_open_access"
  puts "#{dataset_path}_pd_world"
  puts "#{dataset_path}_pd_world_open_access"
end