#!/bin/bash

=begin >/dev/null 2>&1
source "$(dirname $0)/../lib/ruby.sh"
require 'jruby-9.1'
ruby.sh
=end

#!ruby

# ingest.rb
# add missing and outdated volumes to the full dataset

require 'concurrent'
require_relative '../lib/database.rb'
require_relative '../lib/volume.rb'

# ensure presence of scratch space
scratch = '/ram/dataset'
File.directory?(scratch) or FileUtils.mkdir_p(scratch)
File.directory?(scratch) or abort("Cannot create scratch directory #{stratch}")
File.writable?(scratch)  or abort("Cannot write to scratch directory #{stratch}")

worker_pool = Concurrent::ThreadPoolExecutor.new(
   min_threads: 50,
   max_threads: 50,
   max_queue: 100,
   fallback_policy: :caller_runs
)

HTDB.items_to_ingest.select(:namespace,:id).each do |row|
  worker_pool.post do
    volume = Volume.new(row[:namespace],row[:id])
    volume.ingest
  end
end

HTDB.items_to_reingest.each do |row|
  worker_pool.post do
    volume = Volume.new(row[:namespace],row[:id])
    volume.ingest
  end
end

worker_pool.shutdown
