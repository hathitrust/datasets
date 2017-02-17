require "i_volume_repo"
require "i_link_area"
require "link_builder"
require "filter"

# Deletes volumes from a dataset
class Deleter

  # @param [IVolumeRepo] volume_repo
  # @param [ILinkArea] link_area
  # @param [LinkBuilder] link_builder
  # @param [Filter] filter
  # @param [Time] last_run_time
  def initialize(volume_repo:, link_area:, link_builder:, filter:, last_run_time:)
    @volume_repo = volume_repo
    @link_area = link_area
    @link_builder = link_builder
    @filter = filter
    @last_run_time = last_run_time
  end

  def delete
    volumes = volume_repo.changed_since(last_run_time)
    deleted_volumes = volumes - filter.filter(volumes)
    deleted_volumes
      .map{|volume| link_builder.link(volume) }
      .each{|link| link_area.save(link) }
  end

  private

  attr_reader :volume_repo, :link_area, :link_builder,
    :filter, :last_run_time

end
