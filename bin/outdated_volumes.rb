# outdated_volumes.rb
# lists volumes that should be in the full in copyright dataset, but aren't

require_relative '../lib/database.rb'

HTDB.items_to_reingest.each do |hash|
  puts "#{hash[:namespace]}\t#{hash[:id]}"
end
