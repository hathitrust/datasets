#!/bin/bash

=begin >/dev/null 2>&1
source "$(dirname $0)/../lib/ruby.sh"
require '2.2'
ruby.sh
=end

#!ruby

# notify.rb
# notify.rb [--urgent-only] [--dry-run]
# send notifications to users about recent deletes

require 'net/smtp'
require_relative '../lib/database.rb'

urgent_only = false
dry_run = false

deletes = HTDB.notifications(urgent_only: urgent_only).select(:namespace,:id)

def email(set_name,recipient,data)
  (data.count < 1) and return

  message = <<DOC
From: HathiTrust <feedback@issues.hathitrust.org>
To: #{recipient}
Subject: Delete notifications for #{set_name} dataset


Dear HathiTrust dataset recipient,

What follows is a list of HathiTrust volumes formerly in the \"#{set_name}\" dataset that no longer meet the criteria for inclusion. In accordance with our terms of use, please delete all copies you retain of these volumes and reply to this email to confirm these volumes have been deleted.

If you no longer possess HathiTrust datasets, or if you have other questions regarding datasets, then please email feedback@issues.hathitrust.org.

Thank you.

HathiTrust

===BEGIN ID LIST===
DOC
  data.each do |item|
    message+="#{item[:namespace]}.#{item[:id]}\n"
  end
  message+="\n\n===END ID LIST===\n"

  Net::SMTP.start('localhost') do |smtp|  
    smtp.send_message message, 'feedback@issues.hathitrust.org', recipient    
  end
end

# ht_text = deletes.where(:in_copyright => true)
email('ht_text_pd','ht-dataset-pd@umich.edu',deletes.where(:pd_us => true))
email('ht_text_pd_open_access','ht-dataset-pd-oa@umich.edu',deletes.where(:open_access => true))
email('ht_text_pd_world','ht-dataset-pd-world@umich.edu',deletes.where(:pd_world => true))
email('ht_text_pd_world_open_access','ht-dataset-pd-world-oa@umich.edu',deletes.where(:world_open_access => true))

unless (dry_run)
  HTDB.purge_notifications(only_urgent)
end
