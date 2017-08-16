#!ruby

# notify.rb
# notify.rb [--urgent-only] [--dry-run]
# send notifications to users about recent deletes

require 'net/smtp'

deletes = ARGF.readlines.map { |l| l.strip.split("\t") }

def email(set_name,recipient,data)
  (data.count < 1) and return

  message = <<DOC
From: HathiTrust <feedback@issues.hathitrust.org>
To: #{recipient}
Subject: Delete notifications for #{set_name} dataset


Dear HathiTrust dataset recipient,

What follows is a list of HathiTrust volumes formerly in the \"#{set_name}\" dataset that no longer meet the criteria for inclusion. In accordance with our terms of use, please delete all copies you retain of these volumes.

If you no longer possess HathiTrust datasets, or if you have other questions regarding datasets, then please email feedback@issues.hathitrust.org.

Thank you.

HathiTrust

===BEGIN ID LIST===
DOC
  data.each do |item|
    message+="#{item[1]}\n"
  end
  message+="===END ID LIST===\n"

  puts "sending message with #{data.count} deletes to #{recipient}"
  Net::SMTP.start('localhost') do |smtp|  
    smtp.send_message message, 'feedback@issues.hathitrust.org', recipient    
  end
end

dataset_emails = [
  ['ht_text_pd','dataset-pd','pd'],
  ['ht_text_pd_open_access','dataset-pd-oa','pd_open'],
  ['ht_text_pd_world','dataset-pd-world','pd_world'],
  ['ht_text_pd_world_open_access','dataset-pd-world-oa','pd_world_open']
]

dataset_emails.each do |subset_full_name,email,subset_short_name| 
  email(subset_full_name,"#{email}@hathitrust.org",deletes.select { |i| i[0] == subset_short_name }.sort)
end
