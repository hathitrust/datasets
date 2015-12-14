require_relative './config.rb'
require 'sequel'

module HTDB

  def self.get
    @@connection ||= self.connect
  end

  def self.connect
    user = HTConfig.config['database']['user']
    password = HTConfig.config['database']['password']
    host = HTConfig.config['database']['host']
    port = 3306
    database = HTConfig.config['database']['database']

    conection = nil
    if defined?(::PLATFORM) and ::PLATFORM=='java'
      connection = Sequel.connect("jdbc:mysql://#{host}:#{port}/#{database}?user=#{user}&password=#{password}")
    else
      connection = Sequel.connect("mysql2://#{user}:#{password}@#{host}:#{port}/#{database}")
    end
    connection
  end
  # private_class_method :connect

  # get Sequel dataset representing lists of volumes matching certain rights creiteria
  def self.rights_volumes_all
    db = self.get
    db[:rights_current].filter(:access_profile=>[1,2]).exclude(:attr=>[2,8])
  end

  def self.rights_volumes_pd
    self.rights_volumes_all.filter(:attr=>[1,7,9,10,11,12,13,14,15,17,20,21,22,23,24,25])
  end

  # items missing from full set
  def self.items_to_ingest
    self.rights_volumes_all.natural_left_join(:dataset_tracking).filter(:zip_date=>nil)
  end

  # items in full set missing from one or more subsets
  def self.items_to_link
    self.rights_volumes_pd.natural_left_join(:dataset_tracking).exclude(:zip_date=>nil).where('(pd_us IS NULL) OR (pd_world IS NULL and attr != 9) OR (open_access IS NULL and access_profile = 1)')
  end

  # items to remove from all sets (including full)
  def self.items_to_delete

  end

  # items in one or more subsets where they don't belong
  def self.items_to_unlink

  end

  def self.warn(namespace=>nil,id=>nil,volume=>nil,message=>nil,detail=>nil,stage=>nil)
    namespace ||= volume.namespace
    id ||= volume.id

    db = self.get
    db[:feed_log].insert(:namespace=>namespace,:id=>id,:message=>message,:detail=>detail,:stage=>stage,:level=>'WARN')
  end
end
