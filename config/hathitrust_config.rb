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
          end
          .concat([superset, superset_volume_writer])
          .to_h
      end

      def src_path_resolver
        @src_path_resolver ||=
          src_parent_dir.map do |profile, dir|
            [profile, PairtreePathResolver.new(Pathname.new(dir))]
          end
          .to_h
      end

      def volume_repo
        @volume_repo ||=
          subsets.map do |subset|
            [subset, subset_volume_repo]
          end
          .concat([superset, superset_volume_repo])
          .to_h
      end

      def feed_db_connection
        @feed_db_connection ||= Sequel.connect(db[:feed])
      end

      def rights_db_connection
        @rights_db_connection ||= Sequel.connect(db[:rights])
      end

      def filter
        @filter ||= {
          superset => FullSetFilter.new,
          pd: PdFilter.new,
          pd_open: PdOpenFilter.new,
          pd_world: PdWorldFilter.new,
          pd_world_open: PdWorldOpenFilter.new
        }
      end

      private

      def subset_volume_repo
        @rights_volume_repo ||= RightsVolumeRepo.new(rights_db_connection)
      end

      def superset_volume_repo
        @superset_volume_repo ||= RightsFeedVolumeRepo.new(
          RightsVolumeRepo.new(rights_db_connection),
          FeedBackend.new(feed_db_connection)
        )
      end

      def subset_volume_writer(profile)
        VolumeLinker.new(
          id: subset,
          dest_path_resolver: PairtreePathResolver.new(dest_parent_dir[subset]),
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

      def profiles
        subsets + superset
      end

      def subsets
        [:pd, :pd_open, :pd_world, :pd_world_open]
      end

      def superset
        [:full]
      end
    end

  end
end

