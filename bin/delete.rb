# delete.rb
# remove volumes from dataset based on rights criteria

require 'concurrent'
require_relative './database.rb'
require_relative './volume.rb'

worker_pool = Concurrent::ThreadPoolExecutor.new(
   min_threads: 50,
   max_threads: 50,
   max_queue: 100,
   fallback_policy: :caller_runs
)

HTDB.items_to_delete.select(:namespace,:id).each do |row|
  worker_pool.post do
    volume = Volume.new(row[:namespace],row[:id])
    volume.delete
  end  
end

HTDB.items_to_delink_from_all.select(:namespace,:id).each do |row|
  worker_pool.post do
    volume = Volume.new(row[:namespace],row[:id])
    volume.delink
  end  
end

HTDB.items_to_delink_from_open_access.select(:namespace,:id).each do |row|
  worker_pool.post do
    volume = Volume.new(row[:namespace],row[:id])
    volume.delink_open_access
  end  
end

HTDB.items_to_delink_from_world.select(:namespace,:id).each do |row|
  worker_pool.post do
    volume = Volume.new(row[:namespace],row[:id])
    volume.delink_pd_world
  end  
end

worker_pool.shutdown
