require 'thor'
require 'config'
require 'pp'
require 'sequel'
require 'datasets'

Signal.trap("INT"){
  puts "Interrupt.  Exiting."
  exit
}

module Datasets
  class CLI < Thor

    APP_ROOT = Pathname.new File.expand_path('../../',  __FILE__)

    # Tasks
    desc "all", "Do all the dataset operations."
    def all
      configure unless configured?

      # Check that job queue is empty
      unless job_queue_empty?
        puts "Jobs still enqueued."
        return
      end

      # Make connections to backend
      connection = make_connection(Settings.sequel.to_h)

      feed_backend   = Repository::FeedBackend.new(connection)
      rights_backend = Repository::RightsVolumeRepo.new(connection) 
      volume_repo    = Repository::RightsFeedVolumeRepo.new(rights_backend: rights_backend, feed_backend: feed_backend)

      # Make filesystem machinery
      source_path_resolver = PairtreePathResolver.new(Settings.source_repository)
      volume_writer= VolumeWriter

      # Create Filters
      filters = [
        FullSetFilter.new,
        PdFilter.new,
        PdOpenFilter.new,
        PdWorldFilter.new,
        PdWorldOpenFilter.new
      ]

      # Create Schduler for each filter
      schedulers = filters.map do |filter|
        Scheduler.new(
          volume_repo: volume_repo,
          src_path_resolver: source_path_resolver,
          volume_writer: volume_writer,
          filter: filter, 
          last_run_time: last_run_date)
      end

      # QueueJobs
      schedulers.each do |scheduler|
        scheduler.add
        scheduler.delete
      end

      puts "Done."
    end

    desc "print", "Print configuration."
    def print
      configure unless configured?
      pp Settings.to_hash
    end

    # Non-task cli functions 
    private 

    def configured?
      defined?(Settings) ? true : false
    end

    def configure(config_path=nil)
      unless config_path
        config_path = File.join(APP_ROOT,'config/datasets.yml')
      end

      unless File.exist? config_path
        puts "Unable to read config: #{config_path}"
        exit
      end

      Config.load_and_set_settings(config_path)
    end


    # Functions that should be in a testable orchestration object eventually

    def make_connection(db_info)
      Sequel.connect(db_info)
    end

    def job_queue_empty?
      return true
    end

    def last_run_date
      (Date.today-1).to_time
    end

  end
end
