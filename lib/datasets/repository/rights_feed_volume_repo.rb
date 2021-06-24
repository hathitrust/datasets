require "datasets/repository/rights_volume_repo"

module Datasets
  module Repository
    class RightsFeedVolumeRepo < RightsVolumeRepo

      # Retrieve all unique volumes that have had a changed
      # within the given time period.  The list is unordered.
      # @param [Time] start_time
      # @param [Time] end_time
      # @return Set<Volume>
      def changed_between(start_time, end_time)
        project(
          joined_tables.where(time: start_time..end_time)
          .or(zip_date: start_time..end_time)
          .exclude(md5check_ok: false)
        )
      end

      private


      def joined_tables
        super.join(:feed_audit, namespace: Sequel[table_name][:namespace], id: Sequel[table_name][:id])
      end

      attr_reader :rights_backend, :feed_backend

    end
  end
end
