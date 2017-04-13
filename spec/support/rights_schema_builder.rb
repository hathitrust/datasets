require "csv"

module Datasets
  class RightsSchemaBuilder

    def initialize(connection)
      @connection = connection
    end

    def create!
      create_access_profiles
      create_attributes
      create_reasons
      create_sources
      create_rights_current
      populate!
    end

    def access_profile(id)
      @connection.from(:access_profiles).where(id: id).first
    end

    def attribute(id)
      @connection.from(:attributes).where(id: id).first
    end

    def reason(id)
      @connection.from(:reasons).where(id: id).first
    end

    def source(id)
      @connection.from(:sources).where(id: id).first
    end

    private

    attr_reader :connection

    def config_file(filename)
      @dir ||= File.dirname(File.expand_path(__FILE__))
      File.join @dir, "config", "ht_rights", filename
    end

    def csv(path)
      CSV.read(path, headers: true, header_converters: :symbol, converters: :all)
    end

    def insert_from_csv(name)
      csv(config_file("#{name}.csv")).each do |row|
        connection[name.to_sym].insert(row.to_h)
      end
    end

    def populate!
      [:access_profiles, :attributes, :reasons, :sources].each do |name|
        insert_from_csv(name)
      end
    end

    def create_access_profiles
      connection.create_table(:access_profiles) do
        primary_key :id
        String :name, size: 16, null: false
        String :dscr, text: true, null: false
      end
    end


    def create_attributes
      connection.create_table(:attributes) do
        primary_key :id
        String :type, null: false, default: "access"
        String :name, size: 16, null: false, default: ""
        String :dscr, text: true, null: false
      end
    end

    def create_reasons
      connection.create_table(:reasons) do
        primary_key :id
        String :name, size: 16, null: false, default: ""
        String :dscr, text: true, null: false
      end
    end

    def create_rights_current
      connection.create_table(:rights_current) do
        String :namespace, size: 8, null: false
        String :id, size: 32, null: false, default: ""
        Integer :attr, null: false
        Integer :reason, null: false
        Integer :source, null: false
        Integer :access_profile, null: false
        String :user, size: 32, null: false, default: ""
        Time :time, null: false
        primary_key [:namespace, :id]
      end
    end

    def create_sources
      connection.create_table(:sources) do
        primary_key :id
        String :name, size: 16, null: false, default: ""
        String :dscr, text: true, null: false
        Integer :access_profile
        String :digitization_source, size: 64
      end
    end


  end
end
