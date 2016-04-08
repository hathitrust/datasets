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

  # create volume from a napspace id pair in a string
  # delimiter is expected to match "[\t\., ]+", so extra junk chars are tolerated
  def self.newFromNSID(nsid)
    nsid = nsid.strip
    m = /^(?<namespace>[a-z0-9]+)(?<delim>[\t\., ]+)(?<id>[^\s]+)$/.match(nsid)
    namespace = m[:namespace]
    id = m[:id]
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

  def link
    # determine flags
    pd_us = true
    pd_world = false
    open_access = false
    if (@rights[:attr] != 9)
      pd_world = true
    end
    if (@rights[:access_profile] == 1)
      open_access = true
    end
  
    # link appropriately
    dataset_path = HTConfig.config['dataset_path']
    self._link(dataset_path,"#{dataset_path}_pd")
    if(open_access)
      self._link(dataset_path,"#{dataset_path}_pd_open_access")
    end
    if(pd_world)
      self._link(dataset_path,"#{dataset_path}_pd_world")
    end
    if(pd_world && open_access)
      self._link(dataset_path,"#{dataset_path}_pd_world_open_access")
    end
  
    # write to database
    HTDB.get[:dataset_tracking].where(:namespace=>self.namespace,:id=>self.id).update(:pd_us=>pd_us,:pd_world=>pd_world,:open_access=>open_access)
  end

  def _link(data_tree,link_tree)
    link = self.path(link_tree)
    unless(File.symlink?(link))
      parent_dir = Pathname.new(link).parent
      unless File.directory?(parent_dir)
        FileUtils.mkdir_p(parent_dir)
      end
      FileUtils.ln_s self.path(data_tree), link
    end
  end

  def ingest
    tree = HTConfig.config['dataset_path']
    # check for zip
    unless(File.exist?(self.zip))
      HTDB.warn(:volume=>self,:stage=>'Dataset::Extract',message=>'no zip')
      return
    end
    # get zip date
    date = File.mtime(self.zip)
    txt_size = `unzip -l '#{self.zip}' *.txt | tail -1`.scan(/\d+/)[0].to_i
    unless(txt_size > 0)
      HTDB.info(:volume=>self,:stage=>'Dataset::Extract',message=>'no text',detail=>"no text")
      return
    end
    # ensure link dir
    dir = self.path(tree)
    File.directory?(dir) or FileUtils.mkdir_p(dir)
    # link mets
    mets = self.mets(tree)
    File.symlink?(mets) or FileUtils.ln_s(self.mets,mets)

    zip = self.zip(tree)
    # purge zip if present
    FileUtils.rm_f zip
    # place new zip
    system "cd /ram/dataset; unzip '#{self.zip}' *.txt > /dev/null; zip '#{zip}' '#{self.ptid}'/* > /dev/null; rm -rf '#{self.ptid}'"

    # record action in datasase
    HTDB.get[:dataset_tracking].on_duplicate_key_update.insert(:namespace=>self.namespace,:id=>self.id,:zip_date=>date)
  end

  # reset zip date to the distant past to force a reingest
  # returns the number of affected rows (should be zero or one)
  def reset_zip_date
    date = '1999-09-09 01:01:01'
    HTDB.get[:dataset_tracking].where(:namespace=>self.namespace,:id=>self.id).update(:zip_date=>date)
  end

  def restore_db_entry
    dataset_path = HTConfig.config['dataset_path']
    # look for symlinks
    ic                   = File.file?(self.zip(dataset_path))
    pd                   = File.file?(self.zip("#{dataset_path}_pd"))
    pd_open_access       = File.file?(self.zip("#{dataset_path}_pd_open_access"))
    pd_world             = File.file?(self.zip("#{dataset_path}_pd_world"))
    pd_world_open_access = File.file?(self.zip("#{dataset_path}_pd_world_open_access"))

    # stop if ic item is not found
    ic or return

    pd_us_flag       = false
    pd_world_flag    = false
    open_access_flag = false
  
    # convert list of symlinks to valid db state
    if(pd and pd_open_access and pd_world and pd_world_open_access)
      # pd_us, pd_world, open_access
      pd_us_flag = pd_world_flag = open_access_flag = true
    elsif(!pd and !pd_open_access and !pd_world and !pd_world_open_access)
      # ic only
      pd_us_flag = pd_world_flag = open_access_flag = false
    elsif(pd and !pd_open_access and pd_world and !pd_world_open_access)
      # pd_us, pd_world
      pd_us_flag = pd_world_flag = true
    elsif(pd and pd_open_access and !pd_world and !pd_world_open_access)
      # pd_us, open_access
      pd_us_flag = open_access_flag = true
    elsif(pd and !pd_open_access and !pd_world and !pd_world_open_access)
      # pd_us
      pd_us_flag = true
    else
      # invalid state, default to ic only and issue warning
      HTDB.warn(volume=>self,message=>"invalid link state",detail=>"pd = #{pd}, pd_open_access = #{pd_open_access}, pd_world = #{pd_world}, pd_world_open_access = #{pd_world_open_access}",stage=>"Dataset::RestoreDB")
    end

    # get zip date
    date = File.mtime(self.zip(dataset_path))

    # record state to db
    HTDB.get[:dataset_tracking].on_duplicate_key_update.insert(:namespace=>self.namespace,:id=>self.id,:zip_date=>date,:pd_us=>pd_us_flag,:pd_world=>pd_world_flag,:open_access=>open_access_flag)
  end

  def txt_size
    `unzip -l '#{self.zip}' *.txt | tail -1`.scan(/\d+/)[0].to_i
  end

  # args are the current state of the dataset_tacking entry
  def delete(pd_us,pd_world,open_access)
    # remove from full set and all subsets
    dataset_path = HTConfig.config['dataset_path']
    bases=[dataset_path,"#{dataset_path}_pd","#{dataset_path}_pd_open_access","#{dataset_path}_pd_world","#{dataset_path}_pd_world_open_access"]
    bases.each do |base|
      FileUtils.rmtree(self.path(base))
    end
    # record
    HTDB.get[:dataset_deletes].on_duplicate_key_update.insert(:namespace=>self.namespace,:id=>self.id,:in_copyright=>true,:pd_us=>pd_us,:pd_world=>pd_world,:open_access=>open_access,:world_open_access=>(open_access&&pd_world))
    HTDB.get[:dataset_tracking].where(:namespace=>self.namespace,:id=>self.id).delete
  end

  def delink(pd_us,pd_world,open_access)
    # remove from all subsets 
    dataset_path = HTConfig.config['dataset_path']
    bases=["#{dataset_path}_pd","#{dataset_path}_pd_open_access","#{dataset_path}_pd_world","#{dataset_path}_pd_world_open_access"]
    bases.each do |base|
      FileUtils.rmtree(self.path(base))
    end
    # record
    HTDB.get[:dataset_deletes].on_duplicate_key_update.insert(:namespace=>self.namespace,:id=>self.id,:pd_us=>pd_us,:pd_world=>pd_world,:open_access=>open_access,:world_open_access=>(open_access&&pd_world))
    HTDB.get[:dataset_tracking].where(:namespace=>self.namespace,:id=>self.id).update(:pd_us=>false,:pd_world=>false,:open_access=>false)
  end

  def delink_open_access(pd_us,pd_world,open_access)
    # delete from OPEN_ACCESS subsets
    dataset_path = HTConfig.config['dataset_path']
    bases=["#{dataset_path}_pd_open_access","#{dataset_path}_pd_world_open_access"]
    bases.each do |base|
      FileUtils.rmtree(self.path(base))
    end
    # record
    HTDB.get[:dataset_deletes].on_duplicate_key_update.insert(:namespace=>self.namespace,:id=>self.id,:open_access=>open_access,:world_open_access=>(open_access&&pd_world))
    HTDB.get[:dataset_tracking].where(:namespace=>self.namespace,:id=>self.id).update(:open_access=>false)
  end

  def delink_pd_world(pd_us,pd_world,open_access)
    # delete from PD_WORLD subsets
    dataset_path = HTConfig.config['dataset_path']
    bases=["#{dataset_path}_pd_world","#{dataset_path}_pd_world_open_access"]
    bases.each do |base|
      FileUtils.rmtree(self.path(base))
    end    
    # record
    HTDB.get[:dataset_deletes].on_duplicate_key_update.insert(:namespace=>self.namespace,:id=>self.id,:pd_world=>pd_world,:world_open_access=>(open_access&&pd_world))
    HTDB.get[:dataset_tracking].where(:namespace=>self.namespace,:id=>self.id).update(:pd_world=>false)
  end

end
