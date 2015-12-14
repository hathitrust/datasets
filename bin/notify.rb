# notify.rb
# notify.rb [--only-urgent] [--dry-run]
# send notifications to users about recent deletes

require_relative './database.rb'

only_urgent = false
dry_run = false

deletes = HTDB.notifications(only_urgent).select(:namespace,:id)

def email(set_name,recipient,data)
  cnt = data.size
  (cnt < 1) and return

  subject = "Delete notifications for #{set_name} dataset"
  body = <<DOC
Dear HathiTrust dataset recipient,

What follows is a list of HathiTrust volumes formerly in the \"#{set_name}\" dataset that no longer meet the criteria for inclusion. In accordance with our terms of use, please delete all copies you retain of these volumes and reply to this email to confirm these volumes have been deleted.

If you no longer possess HathiTrust datasets, or if you have other questions regarding datasets, then please email feedback@issues.hathitrust.org.

Thank you.

HathiTrust

===BEGIN ID LIST===
DOC
  data.each do |item|
    body+="#{item[:namespace]}.#{item.[:id]}\n"
  end
  body+="\n\n===END ID LIST===\n"

  ### send message here ###

end

# ht_text = deletes.where(:in_copyright => true)
email('ht_text_pd','ht-dataset-pd@umich.edu',deletes.where(:pd_us => true))
email('ht_text_pd_open_access','ht-dataset-pd-oa@umich.edu',deletes.where(:open_access => true))
email('ht_text_pd_world','ht-dataset-pd-world@umich.edu',deletes.where(:pd_world => true))
email('ht_text_pd_world_open_access','ht-dataset-pd-world-oa@umich.edu',deletes.where(:pd_world => true, :open_access => true))

unless (dry_run)
  HTDB.purge_notifications(only_urgent)
end
