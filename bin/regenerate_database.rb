# regenerate_database.rb
# crawls filesystem to identify all volume ids and add them to tracking database
# items are added with date of the dataset zip, since the date of the repo zip represented cannot be established

if(defined?(::PLATFORM) and ::PLATFORM=='java')
  raise 'Run with MRI. JRuby does not support Open3.'
end
require 'open3'
require_relative '../lib/config.rb'

dataset_path = HTConfig.config['dataset_path']
puts dataset_path
Open3.pipeline_r("find #{dataset_path} -follow -type f -name '*.zip'") {|o, ts|
  o.each do |line|
    volume = Volume.newFromPath(line)
    volume.restore_db_entry
  end
}