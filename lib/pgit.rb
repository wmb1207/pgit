# frozen_string_literal: true
require 'optparse'
require 'open3'
require 'colorize'

require_relative "pgit/version"

$ssh_key_path = "/Users/#{ENV['USER']}/.ssh"

module Pgit
  class InvalidEmailAddressError < StandardError; end
  class InvalidKeyError < StandardError; end
  class MissingEmailError < StandardError; end
  class Error < StandardError; end
  
  class Main
    def key_exists?(key_name)
      File.exist?("#{$ssh_key_path}/#{key_name}")      
    end

    def new_key(email)
      raise InvalidEmailAddressError.new("Invlaid email address") unless email =~ URI::MailTo::EMAIL_REGEXP
      `ssh-keygen -t ed25519 -C "#{email}"`
    end

    def list_keys
      local_key = File.exist?("#{Dir.pwd}/.pgit") ? File.read("#{Dir.pwd}/.pgit") : ""
      keys = Dir.entries($ssh_key_path).map do |e|
        next unless  !['config', 'known_hosts', '.', '..'].include?(e) 
        e unless e.include?('pub')
      end
      filtered = keys.reject! { |s| s.nil?}
      filtered.each do |f|
        puts(f.strip == local_key.strip ? "* #{f}" : f)
      end
    end

    def run(key_name, git_sub_cmd)
      raise InvalidKeyError.new("Invalid key") unless key_exists?(key_name)
      command = "ssh-agent bash -c 'ssh-add #{$ssh_key_path}/#{key_name}; git #{git_sub_cmd.join(' ')}'"
      stdout, stderr, status = Open3.capture3(command)
      if status != 0
        puts stderr.red
        exit 1
      end

      stdout.split("\n").each do |out|
        case 
        when out.include?("new file:")
          puts out.light_green
        when out.include?("modified:")
          puts out.yellow
        when out.include?("deleted:")
          puts out.light_red
        else
          puts out
        end
      end
    end

    def local_setup(key)
      File.open("#{Dir.pwd}/.pgit", 'w') { |file| file.write(key) }
    end
  end

  def self.run
    begin
      OptionParser.new do |opt|
        opt.on('-n', '--new_key EMAIL') { |email| Main.new.new_key(email); exit 0}
        opt.on('-ls' '--list_keys') { |_| Main.new.list_keys; exit 0 }
        opt.on('--local KEY') { |key|  Main.new.local_setup(key); exit 0 }
        opt.on('-k KEY', '--key KEY') do |key|
          opt.parse!(ARGV)
          Main.new.run(key, ARGV)
          exit 0
        end
      end.parse!
      
      key = File.read("#{Dir.pwd}/.pgit")
      Main.new.run(key, ARGV[0..-1])
    rescue => e
      puts e
    end
  end
end
