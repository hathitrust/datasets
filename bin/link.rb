# link.rb
# add volumes listed on STDIN to the full dataset

require 'concurrent'
require_relative './database.rb'
require_relative './volume.rb'

worker_pool = Concurrent::ThreadPoolExecutor.new(
   min_threads: 50,
   max_threads: 50,
   max_queue: 100,
   fallback_policy: :caller_runs
)

HTDB.items_to_link.select(:namespace,:id,:attr,:access_profile).each do |row|
  worker_pool.post do
    volume = Volume.new(row[:nomespace],row[:id],{attr: row[:attr], access_profile: row[:access_profile]})
    volume.link
  end  
end

worker_pool.shutdown
