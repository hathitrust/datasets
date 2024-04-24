require "datasets/volume_repo"
require "datasets/volume"
require "sequel"

module Datasets
  module Repository
    class RightsVolumeRepo < VolumeRepo
      def initialize(connection)
        @connection = connection
        @table_name = :rights_current
      end

      # Retrieve all unique volumes that have had a change in
      # their rights within the given time period.
      # The list is unordered.
      # @param [Time] start_time
      # @param [Time] end_time
      # @return Set<Volume>
      def changed_between(start_time, end_time)
        project(
          joined_tables.where(time: start_time..end_time)
        )
      end

      def volumes(ids)
        ids.map do |id|
          (namespace, id) = id.split(".", 2)
          project(joined_tables.where(
            Sequel.qualify(table_name, "namespace") => namespace,
            Sequel.qualify(table_name, "id") => id
          ))
            .first
        end
      end

      private

      attr_reader :connection, :table_name

      def project(dataset)
        dataset
          .select(Sequel[table_name][:id])
          .select_append(Sequel[table_name][:namespace])
          .select_append(Sequel.as(Sequel[:access_profiles][:name], :access_profile))
          .select_append(Sequel.as(Sequel[:attributes][:name], :attribute))
          .map { |row| row_to_volume(row) }
      end

      def format_pairs(pairs)
        pairs.map { |h| [h.fetch(:namespace, ""), h.fetch(:id, "")] }
      end

      def joined_tables
        connection[table_name]
          .join(:access_profiles, id: :access_profile)
          .join(:attributes, id: Sequel[table_name][:attr])
          .join(:reasons, id: Sequel[table_name][:reason])
          .join(:sources, id: Sequel[table_name][:source])
      end

      def row_to_volume(row)
        Volume.new(
          namespace: row[:namespace],
          id: row[:id],
          access_profile: row[:access_profile].to_sym,
          right: row[:attribute].to_sym
        )
      end
    end
  end
end
