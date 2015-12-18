# delete.rb
# remove volumes from dataset based on rights criteria

require_relative '../lib/database.rb'
require_relative '../lib/volume.rb'

HTDB.items_to_delete.each do |row|
  volume = Volume.new(row[:namespace],row[:id])
  volume.delete(row[:pd_us],row[:pd_world],row[:open_access])
end

HTDB.items_to_delink_from_all.each do |row|
  volume = Volume.new(row[:namespace],row[:id])
  volume.delink(row[:pd_us],row[:pd_world],row[:open_access])
end

HTDB.items_to_delink_from_open_access.each do |row|
  volume = Volume.new(row[:namespace],row[:id])
  volume.delink_open_access(row[:pd_us],row[:pd_world],row[:open_access])
end

HTDB.items_to_delink_from_world.each do |row|
  volume = Volume.new(row[:namespace],row[:id])
  volume.delink_pd_world(row[:pd_us],row[:pd_world],row[:open_access])
end
