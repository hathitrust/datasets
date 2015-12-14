require 'yaml'
# load configuration from yaml file, provide access to said config

module HTConfig  
  @@config_file = "#{File.dirname(__FILE__)}/../etc/conf.yml"
  @@config = YAML.load_file(@@config_file)

  def self.config
    return @@config
  end
  
  def self.foo
    return "hello"
  end
end
