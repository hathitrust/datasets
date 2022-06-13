require "datasets/volume"
require "sidekiq"

module Datasets
  class Job
    include Sidekiq::Job

    def self.enqueue(*params)
      perform_async(*serialize(*params))
    end

    # Reinvent HashWithIndifferentAccess
    def deserialize_volume(hash)
      Volume.new(
        namespace: hash[:namespace] || hash["namespace"],
        id: hash[:id] || hash["id"],
        access_profile: hash[:access_profile] || hash["access_profile"],
        right: hash[:right] || hash["right"]
      )
    end

  end
end
