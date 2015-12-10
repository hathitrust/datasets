#!/usr/bin/ruby
require 'pairtree'
require 'threach'

re = /^(?<ns>[a-z0-9]+)\.(?<id>.+)$/

link_dir = '/htprep/datasets/full_set/obj'
#target_dir = '/htprep/datasets/english_pd__no_open_access_volumes__/obj.new.faster'
#target_dir = '/htprep/datasets/fake_set/obj.new.faster'
#target_dir = '/htapps/rrotter.babel/fake_setJJ/obj.new.faster'
#target_dir = '/htprep/datasets/english_pd__no_open_access_volumes__/obj.new.better'
#target_dir = '/htprep/datasets/english_pd__no_open_access_volumes__/obj/MISSING_VOLUMES'
target_dir = '/htprep/datasets/english_non_serials_1700_1900/obj.new.1436156580'

FileUtils.mkdir_p target_dir

ARGF.threach(64) do |line|
  m = re.match line
  if m
    ns = m[:ns]
    id = m[:id]
    ppath = Pairtree::Path.id_to_path id
    pdirname = File.dirname ppath

    FileUtils.mkdir_p "#{target_dir}/#{ns}/pairtree_root/#{pdirname}"
    FileUtils.ln_s "#{link_dir}/#{ns}/pairtree_root/#{ppath}", "#{target_dir}/#{ns}/pairtree_root/#{ppath}"
  else
    STDERR.puts "#{line} invalid"
  end
end

