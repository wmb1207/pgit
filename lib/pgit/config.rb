# frozen_string_literal: true

require 'yaml'

# Config descriptor
class Config
  class MissingServicesInConfigFile < StandardError; end

  # Service descriptor
  class Service
    attr_accessor :name, :description, :host, :keywords, :key

    def initialize(name, description, host, keywords, key)
      @name = name
      @description = description
      @host = host
      @key = key
      @keywords = keywords
    end
  end

  # Key config descriptor
  class Key
    attr_accessor :name, :email

    def initialize(name, email)
      @name = name
      @email = email
    end
  end

  attr_accessor :services, :config_path

  def initialize(config_path = "/Users/#{ENV['USER']}/.pgit")
    Dir.mkdir(config_path, 0o0700) unless File.directory?(config_path)
    @config_path = config_path
    @services = read_config_file
  end

  def read_config_file
    unstructure_data = YAML.load_file("/Users/#{ENV['USER']}/.pgit/config.yml")

    raise MissingServicesInCofigFile unless unstructure_data.key?('services')

    @services = parse_services(unstructure_data['services'])
  end

  def parse_services(services)
    services.map do |service|
      Service.new(service['name'], service['description'], service['host'], service['keywoards'],
                  Key.new(service['key']['name'], service['key']['email']))
    end
  end

  def self.get
    Config.new
  end

  def self.default_cfg
    key = Key.new('id_rsa', 'your_amazing_email@email.com')
    service = Service.new('demo', 'a demo service', 'github', 'demo,demito,demote', key)
    cfg = Config.new
    cfg.services = [service]
    yaml_data = YAML.dump(cfg)
    File.open(cfg.default_config_path, 'w') do |file|
      file.write(yaml_data)
    end
  end

  def default_config_path
    "/Users/#{ENV['USER']}/.pgit/config.yml"
  end
end
