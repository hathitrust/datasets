require "datasets/jobs/create_job"
require "datasets/jobs/delete_job"

# Adds volumes to a dataset
class Scheduler

  # @param [VolumeRepo] volume_repo
  # @param [PathResolver] src_path_resolver
  # @param [VolumeWriter] volume_writer
  # @param [Filter] filter
  # @param [Time] last_run_time
  def initialize(volume_repo:, src_path_resolver:, volume_writer:, filter:, last_run_time:)
    @volume_repo = volume_repo
    @src_path_resolver = src_path_resolver
    @volume_writer = volume_writer
    @filter = filter
    @last_run_time = last_run_time
  end

  def add
    volumes = volume_repo.changed_between(last_run_time, Time.now)
    volumes.select { |v| filter.matches?(v) }
      .map{|volume| [volume, src_path_resolver.path(volume)] }
      .map{|volume, src_path| CreateJob.new(volume, src_path, volume_writer) }
      .each{|job| job.enqueue }
  end

  def delete
    volumes = volume_repo.changed_between(last_run_time, Time.now)
    volumes.select { |v| !filter.matches?(v) }
      .map{|volume| DeleteJob.new(volume, volume_writer) }
      .each{|job| job.enqueue }
  end

  private

  attr_reader :volume_repo, :src_path_resolver,
    :volume_writer, :filter, :last_run_time

end
