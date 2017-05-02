require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "resque/tasks"
require "resque/pool/tasks"
require "resque/scheduler/tasks"

RSpec::Core::RakeTask.new(:spec)


namespace :resque do
  task :setup => :server_setup do
    require "datasets"
  end

  task :server_setup do
    require "resque/server"
    require "resque-retry"
    require "resque-retry/server"
    require "resque-scheduler"
    require "resque/scheduler/server"
  end

  namespace :pool do
    task :setup => "resque:setup" do
      Resque::Pool.after_prefork do |_|
        Resque.redis.client.reconnect
      end
    end
  end

  task :scheduler => :setup


end
