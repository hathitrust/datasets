require "datasets/volume_repo"

module Datasets
  module Repository
    class RightsFeedVolumeRepo < VolumeRepo

      def initialize(rights_backend:, feed_backend:)
        @rights_backend = rights_backend
        @feed_backend = feed_backend
      end

      # Retrieve all unique volumes that have had a changed
      # within the given time period.  The list is unordered.
      # @param [Time] start_time
      # @param [Time] end_time
      # @return Set<Volume>
      def changed_between(start_time, end_time)
        tuples_from_feed = feed_backend.changed_between(start_time, end_time)
        rights_backend.in(tuples_from_feed)
          .merge rights_backend.changed_between(start_time, end_time)
      end

      private

      attr_reader :rights_backend, :feed_backend

    end
  end
end
