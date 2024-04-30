# frozen_string_literal: true

require_relative "spec_helper"
require "cli"

module Datasets
  RSpec.describe CLI do
    let(:config) { double("config") }
    let(:start_date) { "1970-01-01" }
    let(:end_date) { "1970-01-02" }
    let(:volumes) { ["test.0001", "test.0002", "test.003"] }
    let(:time_range) { DateTime.parse(start_date).to_time..DateTime.parse(end_date).to_time }

    before(:each) do
      allow(Datasets::HathiTrust::Configuration).to receive(:from_yaml)
        .and_return(config)

      allow(config).to receive(:profiles).and_return(profiles)
    end

    context "with no profiles" do
      let(:profiles) { [] }

      it "does not accept garbage parameters" do
        expect do
          described_class.start(%w[I don't know what I'm doing])
        end.to output(/Could not find command/).to_stderr
      end

      it "loads the given config" do
        some_config = "config/whatever"
        expect(Datasets::HathiTrust::Configuration).to receive(:from_yaml)
          .with(some_config)

        described_class.start(["-c", some_config])
      end
    end

    context "with configured profiles" do
      let(:profiles) { [:one, :two] }

      it "does not run anything if there is a start date without an end date" do
        expect(ManagedSafeRun).not_to receive(:new)
        expect(UnmanagedSafeRun).not_to receive(:new)

        described_class.start(["--start-time", start_date])
      end

      it "does not accept an end date without an start date" do
        expect(ManagedSafeRun).not_to receive(:new)
        expect(UnmanagedSafeRun).not_to receive(:new)

        described_class.start(["--end-time", end_date])
      end

      it "runs a managed safe run with each profile in the config" do
        managed_run = double("managed run")
        allow(ManagedSafeRun).to receive(:new).and_return(managed_run)

        expect(ManagedSafeRun).to receive(:new).once
        expect(managed_run).to receive(:execute).once

        described_class.start([])
      end

      it "runs an unmanaged safe run with the given time range for each profile in the config" do
        unmanaged_run = double("unmanaged run")
        allow(UnmanagedSafeRun).to receive(:new).and_return(unmanaged_run)

        expect(UnmanagedSafeRun).to receive(:new).with(time_range).once
        expect(unmanaged_run).to receive(:execute).once

        described_class.start(["--start-time", start_date, "--end-time", end_date])
      end

      it "runs a htid safe run with the given ids and the force_update profile" do
        htid_run = double("htid run")
        old_stdin = $stdin
        begin
          $stdin = StringIO.new(volumes.join("\n"))
          allow(HTIDSafeRun).to receive(:new).and_return(htid_run)
          expect(HTIDSafeRun).to receive(:new).with(volumes).once
          expect(htid_run).to receive(:queue_and_report).with(:force_full).once

          described_class.start(["force"])
        ensure
          $stdin = old_stdin
        end
      end

      it "runs notification processes when given the notify flag" do
        files = ["deletelog1", "deletelog2"]
        notification = double("notification")
        allow(Notify).to receive(:new).and_return(notification)
        expect(Notify).to receive(:new).with(files, dry_run: true, smtp_host: "localhost").once
        expect(notification).to receive(:notify).once

        described_class.start(["notify", "--dry-run", "deletelog1", "deletelog2"])
      end
    end
  end
end
