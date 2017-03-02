require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "resque/tasks"
require "resque/pool/tasks"
require "resque/scheduler/tasks"

RSpec::Core::RakeTask.new(:spec)

task :environment do
  require "datasets"
end


namespace :resque do

  task :setup => :environment do
    require "resque"
    Resque.redis = 'localhost:6379'
  end

  namespace :pool do
    task :setup => "resque:setup" do
      require "resque/pool"
      Resque::Pool.after_prefork do |job|
        Resque.redis.client.reconnect
      end
    end
  end

  task :setup_schedule => :setup do
    require "resque-scheduler"
    require "resque/scheduler/server"
    # Resque::Scheduler.dynamic = true
    Resque.schedule = YAML.load(File.read('config/resque-schedule.yml'))
  end
  task :scheduler => :setup_schedule

end
