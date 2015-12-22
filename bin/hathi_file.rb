#!/bin/bash

=begin >/dev/null 2>&1
source "$(dirname $0)/../lib/ruby.sh"
require '2.2'
ruby.sh $@
=end

#!ruby

# usage: hathi_file.rb <file_to_load>

require_relative '../lib/database.rb'
DB=HTDB.get

headings = [:namespace,:id,:rec,:pubdate,:lang,:gov]
rows = []
ARGF.each do |line|
  htid,access,rights,rec,enum_cron,src,src_rec,oclc,isbn,issn,lccn,title,imprint,reason,update,gov,pubdate,pub_place,lang,bib_fmt = line.split("\t")

  namespace,id = htid.split('.',2)
  rows << [namespace,id,rec,pubdate,lang,gov]

  if rows.length >= 2000
    DB[:hathi_file].on_duplicate_key_update.import(headings,rows)
    puts rows[0].join(',')
    rows = []
  end
end
