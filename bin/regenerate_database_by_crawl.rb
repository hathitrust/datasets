# regenerate_database.rb
# crawls filesystem to identify all volume ids and add them to tracking database
# items are added with date of the dataset zip, since the date of the repo zip represented cannot be established

# if(defined?(::PLATFORM) and ::PLATFORM=='java')
#   raise 'Run with MRI. JRuby does not support Open3.'
# end
require 'open3'
require_relative '../lib/config.rb'
require_relative '../lib/volume.rb'

dataset_path = HTConfig.config['dataset_path']
audit_path = dataset_path

if(ARGV.size > 0)
  if(ARGV.size == 1)
    path = ARGV[0].chomp
    if path.start_with?(dataset_path)
      audit_path = path
    else
      puts "#{path} is not valid, as it is not a subdirectory of #{dataset_path}"
      exit 1
    end    
  else
    puts "Too many args"
    exit 1
  end
end

puts "auditing dataset at #{dataset_path} starting from #{audit_path}"

Open3.pipeline_r("find '#{audit_path}' -follow -type f -name '*.zip'") {|o, ts|
  o.each do |line|
    volume = Volume.newFromPath(line)
    volume.restore_db_entry
  end
}
