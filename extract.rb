require 'byebug'
require 'zip'
require_relative './volume.rb'
#item = Volume.new('uc2','ark:/13960/t3jw8d85j')
#item = Volume.new('mdp','39015081446166')
item = Volume.new('mdp','39015039663813')

zipfile_name = "/ram/dataset_test.zip"

# Zip::OutputStream.open(zipfile_name) do |zos|
#   Zip::File.open(item.repo_zip) do |repo_z|
#     repo_z.each do |entry|
#       if entry.name.match /\.txt$/
#         zos.put_next_entry entry.name
#         zos.puts entry.get_input_stream.read
#       end
#     end
#   end
# end

puts "cd /ram; unzip #{item.repo_zip} *.txt > /dev/null; zip #{item.zip} #{item.id}/* > /dev/null; rm -r #{item.id}"
