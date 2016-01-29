require_relative './config.rb'
require 'sequel'

PD_RIGHTS_ATTRS = [1,7,9,10,11,12,13,14,15,17,18,20,21,22,23,24,25]

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
    db[:rights_current].filter(:access_profile=>[1,2]).exclude(:attr=>[8,26])
  end

  def self.rights_volumes_pd
    self.rights_volumes_all.filter(:attr=>PD_RIGHTS_ATTRS)
  end

  # items missing from full set
  def self.items_to_ingest
    self.rights_volumes_all.natural_left_join(:dataset_tracking).filter(:zip_date=>nil)
  end

  # items in full set missing from one or more subsets
  def self.items_to_link
    self.rights_volumes_pd.natural_left_join(:dataset_tracking).exclude(:zip_date=>nil).where('(pd_us IS FALSE) OR (pd_world IS FALSE and attr != 9) OR (open_access IS FALSE and access_profile = 1)')
  end

  # items out of date in full set
  def self.items_to_reingest
    self.get[:feed_audit].join(:dataset_tracking, 'feed_audit.namespace = dataset_tracking.namespace AND feed_audit.id = dataset_tracking.id AND feed_audit.zip_date > dataset_tracking.zip_date')
  end

  # items to remove from all sets (including full)
  def self.items_to_delete
    self.get[:dataset_tracking].natural_left_join(:rights_current).where(:attr=>[8,26,nil])
  end

  # items in one or more subsets where they don't belong
  def self.items_to_delink_from_all
    self.get[:dataset_tracking].natural_left_join(:rights_current).where(:pd_us=>true).exclude(:attr=>PD_RIGHTS_ATTRS,:access_profile=>[1,2])
  end
  def self.items_to_delink_from_open_access
    self.get[:dataset_tracking].natural_left_join(:rights_current).where(:open_access=>true,:access_profile=>2)
  end
  def self.items_to_delink_from_world
    self.get[:dataset_tracking].natural_left_join(:rights_current).where(:pd_world=>true,:attr=>9)
  end

  def self.notifications(urgent_only: false)
    q = self.get[:dataset_deletes]
    if(urgent_only)
      q = q.where(:urgent=>true)
    end
    return q
  end

  def self.items(subset: nil)
    q = self.get[:dataset_tracking]
    return q unless(subset)
    case subset
    when 'ht_text_pd'
      q = q.where(:pd_us=>true)
    when 'ht_text_pd_open_access'
      q = q.where(:pd_us=>true,:open_access=>true)
    when 'ht_text_pd_world'
      q = q.where(:pd_world=>true)
    when 'ht_text_pd_world_open_access'
      q = q.where(:pd_world=>true,:open_access=>true)
    when 'ht_text'
      # no nothing
    else
      raise "invalid subset: #{subset}"
    end

    q
  end

  def self.purge_notifications(urgent_only: false)
    self.notifications(urgent_only: urgent_only).delete
  end

  def self.info(namespace: nil,id: nil,volume: nil,message: nil,detail: nil,stage: nil)
    self.log(level: 'info',namespace: namespace,id: id,volume: volume,message: message,detail: detail,stage: stage)
  end

  def self.warn(namespace: nil,id: nil,volume: nil,message: nil,detail: nil,stage: nil)
    self.log(level: 'warn',namespace: namespace,id: id,volume: volume,message: message,detail: detail,stage: stage)
  end

  def self.log(namespace: nil,id: nil,volume: nil,message: nil,detail: nil,stage: nil,level: nil)
    namespace ||= volume.namespace
    id ||= volume.id

    db = self.get
    db[:feed_log].insert(:namespace=>namespace,:id=>id,:message=>message,:detail=>detail,:stage=>stage,:level=>'WARN')
  end


end
