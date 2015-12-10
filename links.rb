#!/usr/bin/ruby
require 'pairtree'

re = /^(?<ns>[a-z0-9]+)\.(?<id>.+)$/

require 'thread'
mutex = Mutex.new

link_dir = '/htprep/datasets/full_set/obj'
#target_dir = '/htprep/datasets/english_pd__no_open_access_volumes__/obj.new.faster'
#target_dir = '/htprep/datasets/fake_set/obj.new.faster'
#target_dir = '/htapps/rrotter.babel/fake_setJJ/obj.new.faster'
target_dir = '/htprep/datasets/english_pd__no_open_access_volumes__/obj'

jobs = []
ARGF.each do |line|
  m = re.match line
  if m
    jobs << m
  else
    STDERR.puts "#{line} invalid"
  end
end

puts "File in memory. Let's get this party started."

FileUtils.mkdir_p target_dir
threads = []

64.times do
  threads << Thread.new do
    loop do
      mutex.synchronize do
        Thread.current[:m] = jobs.pop or Thread.current.exit
      end

      ns = Thread.current[:m][:ns]
      id = Thread.current[:m][:id]
      ppath = Pairtree::Path.id_to_path id
      pdirname = File.dirname ppath
      
      FileUtils.mkdir_p "#{target_dir}/#{ns}/pairtree_root/#{pdirname}"
      FileUtils.ln_s "#{link_dir}/#{ns}/pairtree_root/#{ppath}", "#{target_dir}/#{ns}/pairtree_root/#{ppath}"
    end
  end
end

threads.each do |thread|
    thread.join
end

puts "done"
