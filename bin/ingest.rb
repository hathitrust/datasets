# ingest.rb
# add missing and outdated volumes to the full dataset

require 'concurrent'
require_relative './database.rb'
require_relative './volume.rb'

worker_pool = Concurrent::ThreadPoolExecutor.new(
   min_threads: 50,
   max_threads: 50,
   max_queue: 100,
   fallback_policy: :caller_runs
)

HTDB.items_to_ingest.select(:namespace,:id).each do |row|
  worker_pool.post do
    volume = Volume.new(row[:nomespace],row[:id])
    volume.ingest
  end  
end

HTDB.items_to_reingest.select(:namespace,:id).each do |row|
  worker_pool.post do
    volume = Volume.new(row[:nomespace],row[:id])
    volume.ingest
  end  
end

worker_pool.shutdown
