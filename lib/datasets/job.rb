require "datasets/volume"

module Datasets
  class Job
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
