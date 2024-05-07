# frozen_string_literal: true

require "thor"
require "sequel"
require "datasets"
require_relative "../../config/hathitrust_config"

Signal.trap("INT") do
  puts "Interrupt.  Exiting."
  exit
end

module Datasets
  class CLI < Thor
    def self.exit_on_failure?
      # If we fail we will raise an exception and Ruby will report the exit
      # status (rather than Thor)
      false
    end

    package_name "datasets"

    APP_ROOT = Pathname.new(__FILE__).expand_path.parent.parent.dirname

    # Global option
    class_option :config,
      type: :string,
      default: "#{APP_ROOT}/config/config.yml",
      aliases: "-c",
      desc: "Path to the configuration file to use."

    # Tasks

    option :dry_run,
      type: :boolean,
      default: false,
      aliases: "-n",
      desc: "Preview email rather than sending"

    option :smtp_host,
      default: "localhost",
      type: :string,
      desc: "Host to use for sending email. Defaults to localhost."

    desc "notify logfile ...", "Collate and send deletion notifications gathered from logs"
    def notify(*files)
      Datasets.config = load_config(options[:config])

      Notify.new(files, dry_run: options[:dry_run], smtp_host: options[:smtp_host]).notify
    end

    option :start_time,
      type: :string,
      aliases: "-s",
      desc: "Run from this start time; must also specify end time"

    option :end_time,
      type: :string,
      aliases: "-e",
      desc: "Run to this end time; must also specify start time"

    desc "all", "Do all the dataset operations."
    def all
      Datasets.config = load_config(options[:config])

      check_time_args

      if options[:start_time] && options[:end_time]
        time_range = DateTime.parse(options[:start_time]).to_time..DateTime.parse(options[:end_time]).to_time
        update_time_range(time_range)
      else
        incremental_update
      end

      puts "Done."
    end

    default_task :all

    desc "force", "Force update of a list of volumes."
    def force
      Datasets.config = load_config(options[:config])

      htids = $stdin.readlines.map { |l| l.strip }
      HTIDSafeRun.new(htids).queue_and_report(:force_full)
    end

    # Non-task cli functions
    private

    def check_time_args
      if (options[:start_time] || options[:end_time]) &&
          !(options[:start_time] && options[:end_time])
        raise RequiredArgumentMissingError,
          "if one of start and end time is given, both must be"
      end
    end

    def incremental_update
      ManagedSafeRun.new.execute
    end

    def update_time_range(time_range)
      UnmanagedSafeRun.new(time_range).execute
    end

    def load_config(config)
      Datasets::HathiTrust::Configuration.from_yaml(config)
    end
  end
end
