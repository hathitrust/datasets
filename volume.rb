require 'pairtree'

class Volume
  attr_reader :namespace, :id

  def initialize(namespace,id,rights=nil)
    @namespace = namespace
    @id = id
    @rights = rights
  end

  def nsid
    @namespace+'.'+@id
  end

  def repo_path
    @repo_path ||= "/sdr1/#{self.path}"
  end

  def mets
    @mets ||= self.ptid+'.mets.xml'
  end 

  def zip
    @zip ||= self.ptid+'.zip'
  end

  def repo_mets
    self.repo_path+'/'+self.mets
  end

  def repo_zip
    self.repo_path+'/'+self.zip
  end
  
  def path
    @path ||= "obj/#{@namespace}/pairtree_root/#{Pairtree::Path.id_to_path @id}"
  end

  # def rights
  #   @rights ||= HTRights.get(@namespace,@id)
  # end

  def ptid
    Pairtree::Identifier.encode @id
  end
end
