# frozen_string_literal: true
require "datasets/jobs/save_job"
require "datasets/jobs/delete_job"

# Adds volumes to a dataset
module Datasets
  class Scheduler
    # @param [VolumeRepo] volume_repo
    # @param [PathResolver] src_path_resolver
    # @param [VolumeWriter] volume_writer
    # @param [Filter] filter
    # @param [Range<Time>] time_range
    def initialize(volume_repo:, src_path_resolver:, volume_writer:, filter:, time_range:)
      @volume_repo = volume_repo
      @src_path_resolver = src_path_resolver
      @volume_writer = volume_writer
      @filter = filter
      @time_range = time_range
    end

    def add
      volumes = volume_repo.changed_between(time_range.first, time_range.last)
        .select {|volume| filter.matches?(volume) }
      volumes
        .map {|volume| [volume, src_path_resolver.path(volume)] }
        .map {|volume, src_path| SaveJob.new(volume, src_path, volume_writer) }
        .each {|job| job.enqueue }
      return volumes
    end

    def delete
      volumes = volume_repo.changed_between(time_range.first, time_range.last)
        .reject {|volume| filter.matches?(volume) }
      volumes
        .map {|volume| DeleteJob.new(volume, volume_writer) }
        .each {|job| job.enqueue }
      return volumes
    end

    private

    attr_reader :volume_repo, :src_path_resolver,
      :volume_writer, :filter, :time_range
  end
end
