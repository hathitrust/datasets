# volume.rb
# abstraction of HathiTrust volume

require 'pairtree'
require_relative './config.rb'
require_relative './database.rb'

REPO = '/sdr1'

class Volume
  attr_reader :namespace, :id

  def initialize(namespace,id,rights: nil)
    @namespace = namespace
    @id = id
    @rights = rights
  end

  def self.newFromPath(path)
    m = /^(?<prefix>.*)\/obj\/(?<namespace>[a-z0-9]+)\/pairtree_root\/(.{1,2}\/)+(?<ptid>[^\/]+)\//.match(path)
    namespace = m[:namespace]
    ptid = m[:ptid]
    id = Pairtree::Identifier.decode(ptid)
    return self.new(namespace,id)
  end

  def nsid
    @namespace+'.'+@id
  end

  def mets(tree=REPO)
    @mets ||= self.ptid+'.mets.xml'
    File.join self.path(tree), @mets
  end 

  def zip(tree=REPO)
    @zip ||= self.ptid+'.zip'
    File.join self.path(tree), @zip
  end
  
  def path(tree=REPO)
    @path ||= "obj/#{@namespace}/pairtree_root/#{Pairtree::Path.id_to_path @id}"
    File.join tree, @path
  end

  # def rights
  #   @rights ||= HTRights.get(@namespace,@id)
  # end

  def ptid
    @ptid ||= Pairtree::Identifier.encode @id
  end
  
  def to_s
    self.nsid
  end

  def link(permissions)
    # get subset flags
  
    # get subset list
  
    # link appropriately
    # watch out for "quote" naming bug
  
    # write to database
  
  end

  def ingest
    # 
  end

  def restore_db_entry
    dataset_path = HTConfig.config['dataset']['dataset_path']
    # look for symlinks
    pd                   = File.file?(self.zip("#{dataset_path}_ht_text_pd"))
    pd_open_access       = File.file?(self.zip("#{dataset_path}_ht_text_pd_open_access"))
    pd_world             = File.file?(self.zip("#{dataset_path}_ht_text_pd_world"))
    pd_world_open_access = File.file?(self.zip("#{dataset_path}_ht_text_pd_world_open_access"))

    pd_us       = false
    pd_world    = false
    open_access = false
    
    # convert list of symlinks to valid db state
    if(pd and pd_open_access and pd_world and pd_open_access)
      # pd_us, pd_world, open_access
      pd_us = pd_world = open_access = true
    elsif(!pd and !pd_open_access and !pd_world and !pd_open_access)
      # ic only
    elsif(pd and !pd_open_access and pd_world and !pd_open_access)
      # pd_us, pd_world
      pd_us = pd_world = true
    elsif(pd and pd_open_access and !pd_world and !pd_open_access)
      # pd_us, open_access
      pd_us = open_access = true
    elsif(pd and !pd_open_access and !pd_world and !pd_open_access)
      # pd_us
      pd_us = true
    else
      # invalid state, default to ic only and issue warning
      HTDB.warn(volume=>self,message=>"invalid link state",detail=>"pd = #{pd}, pd_open_access = #{pd_open_access}, pd_world = #{pd_world}, pd_world_open_access = #{pd_world_open_access}",stage=>"Dataset::RestoreDB")
    end

    # get zip date
    date = File.mtime(self.zip(dataset_path))

    # record state to db
    HTDB.get()[:dataset_tracking].insert(:namespace=>self.namespace,:id=>self.id,:date=>date,:pd_us=>pd_us,:pd_world=>pd_world,:open_access=>open_access})  
  end

  def self.subset_flags(rights)
  end

  def self.subsets_to_link(flags)
    # convert flags to subset list
  
  end
end


