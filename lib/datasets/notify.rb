require "net/smtp"
require "datasets/dedupe_delete_log"

DATASET_EMAILS = [
  ["ht_text_pd", "dataset-pd", "pd"],
  ["ht_text_pd_open_access", "dataset-pd-oa", "pd_open"],
  ["ht_text_pd_world", "dataset-pd-world", "pd_world"],
  ["ht_text_pd_world_open_access", "dataset-pd-world-oa", "pd_world_open"]
]

SUPPORT_EMAIL = "support@hathitrust.org"

module Datasets
  class Notify
    def initialize(files,
      dry_run:,
      smtp_host:)
      @dry_run = dry_run
      @smtp_host = smtp_host
      @delete_logs = Datasets::DedupeDeleteLog.new(files)
    end

    def notify
      deletes = delete_logs.compile_results

      DATASET_EMAILS.each do |subset_full_name, email, subset_short_name|
        email(subset_full_name, "#{email}@hathitrust.org", deletes[subset_short_name])
      end
    end

    private

    attr_reader :dry_run, :delete_logs, :smtp_host, :files

    def email_header(set_name, recipient)
      <<~DOC
        From: HathiTrust <#{SUPPORT_EMAIL}>
        To: #{recipient}
        Subject: Delete notifications for #{set_name} dataset


        Dear HathiTrust dataset recipient,

        This email is to notify you that volumes in the HathiTrust "#{set_name}" dataset, of which you have downloaded all or a subset of files, no longer meet the criteria for inclusion in the dataset, and you no longer are allowed to use them in your research.

        Please review the data you have synced from HathiTrust to check whether you have the volumes listed below. If so, delete all copies you retain of these volumes in accordance with our terms of use. Alternatively, you may delete your copy of the dataset and re-sync to the updated dataset.

        If you no longer possess HathiTrust datasets, or if you have other questions regarding datasets, then please email #{SUPPORT_EMAIL}.

        Thank you,

        HathiTrust

        ===BEGIN ID LIST===
      DOC
    end

    def email(set_name, recipient, data)
      return unless data&.count

      message = email_header(set_name, recipient)

      data.each do |item|
        message += "#{item}\n"
      end
      message += "===END ID LIST===\n"

      puts "sending message with #{data.count} deletes to #{recipient}"
      send_or_preview(message, recipient)
    end

    def send_or_preview(message, recipient)
      if dry_run
        puts "To: #{SUPPORT_EMAIL}, #{recipient}"
        puts
        puts message
      else
        Net::SMTP.start(smtp_host) do |smtp|
          smtp.send_message message, SUPPORT_EMAIL, recipient
        end
      end
    end
  end
end
