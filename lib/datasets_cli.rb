require 'thor'
require 'config'
require 'pp'
require 'sequel'

require_relative '../lib/datasets/repository/feed_backend'
require 'datasets'

Signal.trap("INT"){
  puts "Interrupt.  Exiting."
  exit
}

class DatasetsCLI < Thor

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

    # Get List of Changes
    connection = Sequel.sqlite
    feed = ::Repository::FeedBackend.new(connection)
    changes = feed.changed_between(last_run_date, Date.today)
    
    # Apply Filters and Create Schduler(s)


    # QueueJobs


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
  def job_queue_empty?
    return true
  end

  def last_run_date
    Date.today-1
  end

end
