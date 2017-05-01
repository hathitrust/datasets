require "resque"
require "resque-retry"
require "resque/failure/redis"

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

module Datasets
  class Job
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff
    @backoff_strategy = [60, 300, 600, 3600, 7200]
    @expire_retry_key_after = @backoff_strategy.last + 3600
    @retry_limit = 10

    def self.perform(args)
      self.deserialize(*args).perform
    end

    def enqueue(queue)
      Resque::Job.create(queue.to_sym, self.class, serialize)
    end

    def serialize
      raise NotImplementedError
    end

    def self.deserialize(*args)
      raise NotImplementedError
    end

    private

    # Reinvent HashWithIndifferentAccess
    def self.deserialize_volume(hash)
      Volume.new(
        namespace: hash[:namespace] || hash["namespace"],
        id: hash[:id] || hash["id"],
        access_profile: hash[:access_profile] || hash["access_profile"],
        right: hash[:right] || hash["right"]
      )
    end

  end
end
