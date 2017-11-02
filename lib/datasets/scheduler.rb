# frozen_string_literal: true
require "datasets/jobs/save_job"
require "datasets/jobs/delete_job"

# Adds volumes to a dataset
module Datasets
  class Scheduler
    # @param [PathResolver] src_path_resolver
    # @param [VolumeWriter] volume_writer
    # @param [Filter] filter
    # @param [Retriever] retriever
    def initialize(src_path_resolver:, volume_writer:, filter:, retriever:, save_job: SaveJob, delete_job: DeleteJob )
      @src_path_resolver = src_path_resolver
      @volume_writer = volume_writer
      @filter = filter
      @retriever = retriever
      @save_job = save_job
      @delete_job = delete_job
    end

    def add
      retriever.retrieve
        .select {|volume| filter.matches?(volume) }.tap do |volumes|
        volumes
          .map {|volume| [volume, src_path_resolver.path(volume)] }
          .map {|volume, src_path| save_job.new(volume, src_path, volume_writer) }
          .each {|job| job.enqueue }
      end 
    end

    def delete
      retriever.retrieve
        .reject {|volume| filter.matches?(volume) }.tap do |volumes|
        volumes
          .map {|volume| delete_job.new(volume, volume_writer) }
          .each {|job| job.enqueue }
      end
    end

    private

    attr_reader :src_path_resolver, :volume_writer, :filter, :retriever, :save_job, :delete_job
  end
end
