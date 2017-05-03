require "datasets/volume"
require "resque"

module Datasets
  class Job
    @queue = :work

    def self.queue
      @queue
    end

    def self.inherited(subclass)
      instance_variables.each do |var|
        subclass.instance_variable_set(var, self.instance_variable_get(var))
      end
    end

    def self.perform(args)
      self.deserialize(*args).perform
    end

    def enqueue
      ::Resque.enqueue(self.class, serialize)
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
