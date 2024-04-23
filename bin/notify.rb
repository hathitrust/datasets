#!/usr/bin/env ruby

# notify.rb
# notify.rb [--urgent-only] [--dry-run]
# send notifications to users about recent deletes

require 'net/smtp'
require 'dedupe_delete_log'

def main
  dataset_emails = [
    ['ht_text_pd','dataset-pd','pd'],
    ['ht_text_pd_open_access','dataset-pd-oa','pd_open'],
    ['ht_text_pd_world','dataset-pd-world','pd_world'],
    ['ht_text_pd_world_open_access','dataset-pd-world-oa','pd_world_open']
  ]

  deletes = DedupeDeleteLog.new(ARGV).compile_results

  dataset_emails.each do |subset_full_name,email,subset_short_name| 
    email(subset_full_name,"#{email}@hathitrust.org",deletes[subset_short_name])
  end
end

def email(set_name,recipient,data)
  (data.count < 1) and return

  message = <<DOC
From: HathiTrust <support@hathitrust.org>
To: #{recipient}
Subject: Delete notifications for #{set_name} dataset


Dear HathiTrust dataset recipient,

This email is to notify you that volumes in the HathiTrust \"#{set_name}\" dataset, of which you have downloaded all or a subset of files, no longer meet the criteria for inclusion in the dataset, and you no longer are allowed to use them in your research.

Please review the data you have synced from HathiTrust to check whether you have the volumes listed below. If so, delete all copies you retain of these volumes in accordance with our terms of use. Alternatively, you may delete your copy of the dataset and re-sync to the updated dataset.

If you no longer possess HathiTrust datasets, or if you have other questions regarding datasets, then please email support@hathitrust.org.

Thank you,

HathiTrust

===BEGIN ID LIST===
DOC
  data.each do |item|
    message+="#{item}\n"
  end
  message+="===END ID LIST===\n"

  puts "sending message with #{data.count} deletes to #{recipient}"
  send_or_preview(message,recipient)
end

def send_or_preview(message,recipient)
  if ENV['PREVIEW_EMAIL']
    puts "To: support@hathitrust.org, #{recipient}"
    puts
    puts message
  else
    Net::SMTP.start(ENV['SMTP_HOST'] || 'localhost') do |smtp|  
      smtp.send_message message, 'support@hathitrust.org', recipient
    end
  end
end

main if __FILE__ == $0
