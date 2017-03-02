require "resque"
require "resque-scheduler"
require "resque/scheduler/server"
require "resque-retry"
require "resque-retry/server"
require "datasets"

Resque.redis = "localhost:6379"
Resque.schedule = YAML.load(File.read('./config/resque-schedule.yml'))



