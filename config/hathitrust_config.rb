require "datasets"
require "pathname"
require "sequel"

module Datasets
  module HathiTrust

    class Configuration < Datasets::Configuration
      def volume_writer
        @volume_writer ||=
          subsets.map do |subset|
            [subset, subset_volume_writer(subset)]
          end.to_h.merge({
            superset => superset_volume_writer,
            force_superset => force_superset_volume_writer
          })
      end

      def src_path_resolver
        @src_path_resolver ||= {
          superset => superset_src_path_resolver,
          force_superset => superset_src_path_resolver,
          pd: subset_src_path_resolver,
          pd_open: subset_src_path_resolver,
          pd_world: subset_src_path_resolver,
          pd_world_open: subset_src_path_resolver
        }
      end

      def volume_repo
        @volume_repo ||=
          subsets.map do |subset|
            [subset, subset_volume_repo]
          end.to_h.merge({
            superset => superset_volume_repo,
            force_superset => force_superset_volume_repo
          })
        @volume_repo
      end

      def db_connection
        # Example with logging enabled
        # @db_connection ||= Sequel.connect(db.merge({loggers: [Logger.new($stdout)]}))
        @db_connection ||= Sequel.connect(db)
      end


      def filter
        @filter ||= {
          force_superset => FullSetFilter.new,
          superset => FullSetFilter.new,
          pd: PdFilter.new,
          pd_open: PdOpenFilter.new,
          pd_world: PdWorldFilter.new,
          pd_world_open: PdWorldOpenFilter.new
        }
      end

      def profiles
        subsets + [superset]
      end

      private

      def subset_src_path_resolver
        @subset_src_path_resolver ||= PairtreePathResolver.new(dest_parent_dir[superset])
      end

      def superset_src_path_resolver
        @superset_src_path_resolver ||= PairtreePathResolver.new(Pathname.new(src_parent_dir))
      end

      def subset_volume_repo
        @rights_volume_repo ||= Repository::RightsVolumeRepo.new(db_connection)
      end

      def superset_volume_repo
        @superset_volume_repo ||= Repository::RightsFeedVolumeRepo.new(db_connection)
      end

      def force_superset_volume_repo
        # only need to consult rights, not rights + feed_audit when forcing
        # updates from a list of volumes
        subset_volume_repo
      end

      def subset_volume_writer(profile)
        VolumeLinker.new(
          id: profile,
          dest_path_resolver: PairtreePathResolver.new(dest_parent_dir[profile]),
          fs: Filesystem.new
        )
      end

      def superset_volume_writer
        VolumeCreator.new(
          id: superset,
          dest_path_resolver: PairtreePathResolver.new(dest_parent_dir[superset]),
          writer: ZipWriter.new,
          fs: Filesystem.new
        )
      end

      def force_superset_volume_writer
        ForceVolumeCreator.new(
          id: force_superset,
          dest_path_resolver: PairtreePathResolver.new(dest_parent_dir[superset]),
          writer: ZipWriter.new,
          fs: Filesystem.new
        )
      end

      def subsets
        [:pd, :pd_open, :pd_world, :pd_world_open]
      end

      def superset
        :full
      end

      def force_superset
        :force_full
      end

    end

  end
end

