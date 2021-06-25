require "resque"
require "resque/failure/redis"
require "resque/pool"
require "resque-retry"
require "resque-scheduler"

Resque.redis = "redis:6379"
Resque.redis.namespace = "datasets"
RESQUE_PORT = 9231

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

module Datasets
  class Job
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff
    @backoff_strategy = [1, 5, 10, 60, 1200]
    @expire_retry_key_after = @backoff_strategy.last + 3600
    @retry_limit = 10
  end
end
