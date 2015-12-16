# regenerate_database_by_id.rb
# reads id list from ARGF (stdin/named file), tries to add or correct db entries based on file system content
# if item exists db will be udated to match fs, if it does not exist we don't currently support erasing its row
# items are added with date of the dataset zip, since the date of the repo zip represented cannot be established

require_relative '../lib/config.rb'
require_relative '../lib/volume.rb'

dataset_path = HTConfig.config['dataset_path']

worker_pool = Concurrent::ThreadPoolExecutor.new(
  min_threads: 50,
  max_threads: 50,
  max_queue: 100,
  fallback_policy: :caller_runs
)

ARGF.each do |line|
  worker_pool.post do
    vol = Volume.newFromNSID(line)
    volume.restore_db_entry
  end  
end
