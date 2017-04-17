module Datasets
  class FeedSchemaBuilder

    def initialize(connection)
      @connection = connection
    end

    def create!
      connection.create_table(:feed_audit) do
        String :namespace, size: 8, null: false
        String :id, size: 32, null: false
        Number :sdr_partition, null: true
        Bignum :zip_size, size: 20, null: true
        Time :zip_date, null: true
        Bignum :mets_size, size: 20, null: true
        Time :mets_date, null: true
        Number :page_count, null: true
        Time :lastchecked, null: false
        Time :lastmd5check, null: true
        TrueClass :md5check_ok, null: true
        TrueClass :is_tombstoned, null: true
        primary_key [:namespace, :id]
      end
    end

    private

    attr_reader :connection

  end
end
