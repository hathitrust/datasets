# reset_zip_date.rb
# reads id list from ARGF (stdin/named file), tries to set datestamp in dataset_tracking table
# to an implausible date in the past. This will force re-ingest on the next update.

require_relative '../lib/volume.rb'

worker_pool = Concurrent::ThreadPoolExecutor.new(
  min_threads: 50,
  max_threads: 50,
  max_queue: 100,
  fallback_policy: :caller_runs
)

ARGF.each do |line|
  worker_pool.post do
    vol = Volume.newFromNSID(line)
    vol.reset_zip_date
  end  
end

worker_pool.shutdown
