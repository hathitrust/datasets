# crawler_points.rb <root_path>
# Given a root path of an HT pairtree, generate a list of points to begin crawling from (for rsync, efficient fscrawling, etc)

require 'pathname'

# top dir of tree
START_OF_TREE='obj'
# top of subtree
START_OF_BRANCHES='pairtree_root'
# if the current path is a prefix of any of these strings, keep digging
SPECIAL_BRANCHES=['obj/hvd/pairtree_root','obj/mdp/pairtree_root/39/01/50','obj/mdp/pairtree_root/39/07/60','obj/uc1/pairtree_root']

root=ARGV[0]
root or abort "Can't run without root path"
rootpn=Pathname.new(root)
rootpn.directory? or abort "#{root} is not a directory"
rootpn.absolute? or abort "Please specify an absolute path"

def special(prefix,absolute) 
  relative = absolute.to_s.sub(prefix,'')
  SPECIAL_BRANCHES.each do |branch|
    if (branch.start_with?(relative))
      # puts "#{relative} is special!"
      return true 
    end
  end
  false
end

def dig(dir,in_tree=false,in_branches=false,prefix=nil)
  dir.basename.to_s==START_OF_TREE and in_tree=true
  dir.basename.to_s==START_OF_BRANCHES and in_branches=true
  if(in_tree&&!prefix)
    prefix = (dir.dirname.to_s + '/')
  end

  # eww, get your termination conditions straight
  if(in_branches && !special(prefix,dir))
    return dir.to_s
  end

  leaves = []
  d = Dir.new(dir)
  d.each do |child|
    child.start_with?('.') and next
    child_pn = Pathname.new("#{dir.to_s}/#{child}")
    child_pn.directory? or next
    if(!in_branches || special(prefix,child_pn))
      leaves<<dig(child_pn,in_tree,in_branches,prefix)
    else
      leaves<<child_pn.to_s
    end
  end

  leaves
end

puts dig(rootpn)
