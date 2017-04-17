require 'thor'
require 'config'
require 'pp'
require 'sequel'
require 'datasets'
require 'pry'
require_relative '../config/hathitrust_config'

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
      # TODO: take config yml as a cmdline option
      config = Datasets::HathiTrust::Configuration.from_yaml(File.join(APP_ROOT,"config/integration.yml"))
      Datasets.config = config

      # Check that job queue is empty
      unless job_queue_empty?
        puts "Jobs still enqueued."
        return
      end

      schedulers = config.profiles.map do |profile|
        Scheduler.new(
          volume_repo: config.volume_repo[profile],
          src_path_resolver: config.src_path_resolver,
          volume_writer: config.volume_writer[profile],
          filter: config.filter[profile],
          last_run_time: last_run_date,
          logger: VolumeActionLogger.new(File.open("#{profile}_#{Date.today.to_s}.txt","w")))
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

    # Functions that should be in a testable orchestration object eventually

    def job_queue_empty?
      return true
    end

    # TODO: allow injection
    def last_run_date
#      (Date.today-1).to_time
      Date.new(1970,01,01).to_time
    end

  end
end
