require_relative './config.rb'
require 'sequel'

module HTDB

  def self.get
    @@connection ||= self.connect
  end

  def self.connect
    user = HTConfig.config['database']['user']
    password = HTConfig.config['database']['password']
    host = HTConfig.config['database']['host']
    port = 3306
    database = HTConfig.config['database']['database']

    conection = nil
    if defined?(::PLATFORM) and ::PLATFORM=='java'
      connection = Sequel.connect("jdbc:mysql://#{host}:#{port}/#{database}?user=#{user}&password=#{password}")
    else
      connection = Sequel.connect("mysql2://#{user}:#{password}@#{host}:#{port}/#{database}")
    end
    connection
  end
  # private_class_method :connect

  # get Sequel dataset representing lists of volumes matching certain rights creiteria
  def rights_dataset()
  end

  # items missing from full set

  # items to be linked
  def items_to_link()
    # get things that are pd
    # return namespace, id, attr, reason
    # keep an eye out for the "quote" naming bug
  end

  def items_to_delete()
    # namespace, id, ic, pd_us, pd_world, open_access
  end

end