require "resque"
require "resque/failure/redis"
require "resque/pool"
require "resque-retry"
require "resque-scheduler"

Resque.redis = "localhost:6379"
Resque.redis.namespace = "datasets"
RESQUE_PORT = 9231

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

schedule_path = Pathname.new(__FILE__).dirname + "resque-schedule.yml"
Resque.schedule = YAML.load_file(schedule_path) || {}


module Datasets
  class Job
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff
    @backoff_strategy = [60, 300, 600, 3600, 7200]
    @expire_retry_key_after = @backoff_strategy.last + 3600
    @retry_limit = 10
  end
end
