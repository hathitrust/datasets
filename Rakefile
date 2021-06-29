$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "bundler/setup"
require "rspec/core/rake_task"
require "resque/tasks"
require "resque/pool/tasks"
require "socket"

RSpec::Core::RakeTask.new(:spec)


namespace :resque do
  task :setup => :server_setup do
    require "datasets"
    require_relative "config/hathitrust_config.rb"
    config_yml = Pathname.new(__FILE__).expand_path.dirname + "config" + "config.yml"
    Datasets.config = Datasets::HathiTrust::Configuration.from_yaml(config_yml)
  end

  task :server_setup do
    require "resque/server"
    require "resque-retry"
    require "resque-retry/server"
  end

  namespace :pool do
    task :setup => "resque:setup" do
      Resque::Pool.after_prefork do |worker|

        # set up pipe to rotatelogs
        log_basename = [Socket.gethostname,Process.pid,"%Y%m%d"].join('-')
        FileUtils.mkdir_p Datasets.config.worker_log_path
        log_template = File.join(Datasets.config.worker_log_path,"#{log_basename}.log")
        rotatelogs_cmd = "/usr/bin/rotatelogs -f -l #{log_template} 86400"
        log_io = IO.popen(rotatelogs_cmd,"w")
        log_io.sync = true

        Resque.logger = Logger.new(log_io)
        Resque.logger.level = Logger::INFO
        # ensure workers don't share parent redis connection
        Resque.redis.client.reconnect
        # don't fork a new process for every job - in particular this prevents
        # using a new connection to redis for every job
        worker.fork_per_job = false
      end
    end
  end

#  task :scheduler => :setup

end
