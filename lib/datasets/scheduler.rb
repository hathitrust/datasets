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
    # @param [Time] last_run_time
    # @param [VolumeActionLogger] logger
    def initialize(volume_repo:, src_path_resolver:, volume_writer:, filter:, last_run_time:, logger:)
      @volume_repo = volume_repo
      @src_path_resolver = src_path_resolver
      @volume_writer = volume_writer
      @filter = filter
      @last_run_time = last_run_time
      @logger = logger
    end

    def add
      volume_repo.changed_between(last_run_time, Time.now)
        .select {|v| filter.matches?(v) }
        .map {|volume| [volume, src_path_resolver.path(volume)] }
        .each do |volume, src_path|
        SaveJob.new(volume, src_path, volume_writer).enqueue
        logger.log("save", volume, src_path)
      end
    end

    def delete
      volume_repo.changed_between(last_run_time, Time.now)
        .select {|v| !filter.matches?(v) }
        .each do |volume|
        DeleteJob.new(volume, volume_writer).enqueue
        logger.log("delete", volume, src_path_resolver.path(volume))
      end
    end

    private

    attr_reader :volume_repo, :src_path_resolver,
      :volume_writer, :filter, :last_run_time, :logger
  end
end
