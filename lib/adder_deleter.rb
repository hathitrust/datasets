require "volume_repo"
require "path_resolver"
require "volume_writer"
require "filter"

# Adds volumes to a dataset
class AdderDeleter

  # @param [VolumeRepo] volume_repo
  # @param [PathResolver] source_area
  # @param [VolumeWriter] volume_writer
  # @param [Filter] filter
  # @param [Time] last_run_time
  def initialize(volume_repo:, source_area:, volume_writer:, filter:, last_run_time:)
    @volume_repo = volume_repo
    @source_area = source_area
    @volume_writer = volume_writer
    @filter = filter
    @last_run_time = last_run_time
  end

  def add
    volumes = volume_repo.changed_since(last_run_time)
    filter.filter(volumes)
      .map{|volume| [volume, source_area.src_path(volume)] }
      .each{|volume, src_path| volume_writer.save(volume, src_path) }
      # Only the 'each' step his the filesystem.
      # That is likely the step we want to throw into a job queue.
  end

  def delete
    volumes = volume_repo.changed_since(last_run_time)
    filter.inverse_filter(volumes)
      .each{|volume| volume_writer.delete(volume) }
      # Only the 'each' step his the filesystem.
      # That is likely the step we want to throw into a job queue.
  end

  private

  attr_reader :volume_repo, :source_area, :volume_writer,
    :filter, :last_run_time

end
