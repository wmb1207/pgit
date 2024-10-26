# frozen_string_literal: true

require_relative './config'

# Key descriptor
class Key
  class InvalidEmailAddressError < StandardError; end
  attr_accessor :name, :path, :email

  def initialize(name, path, email)
    @name = name
    @path = path
    @email = email
  end

  def dump
    "#{path}$#{name}$#{email}"
  end

  def self.with_default_path(name, email)
    Key.new(name, Key.default_path, email)
  end

  def exists?
    File.exist?("#{@path}/#{@name}")
  end

  def create
    raise InvalidEmailAddressError unless @email =~ URI::MailTo::EMAIL_REGEXP

    `ssh-keygen -t ed25519 -C "#{@email} -f #{@path}/#{@name}"`
  end

  def delete
    return unless exists?

    `rm -rf #{path}/#{name}`
    `rm -rf #{path}/#{name}.pub`
  end

  def self.list
    cfg = Config.get

    keys = cfg.services.map(&:key)
    keys.uniq.map { |k| Key.new(k.name, "/Users/#{ENV['USER']}/.ssh", k.email) }
  end

  def self.default_path
    "/Users/#{ENV['USER']}/.ssh"
  end

end
