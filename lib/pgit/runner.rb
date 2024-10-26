# frozen_string_literal: true

require_relative './key'
require_relative './config'
require 'open3'
require 'optparse'
require 'colorize'


# Run helper functions
module CLI
  class InvalidKeyError < StandardError; end
  class CMDError < StandardError; end
  class MissingFlagError < StandardError; end

  def self.main
    options = parse

    if options[:init]
      Config.default_cfg
      exit 0
    end

    if options[:new]
      raise MissingFlagError 'Missing email' unless options[:email] != ''

      raise MissingFlagError 'Missing name' unless options[:name] != ''

      key = Key.with_default_path(options[:name], options[:email])
      key.create unless key.exists?
      exit 0
    end

    if options[:list]
      Key.list.each { |k| puts k }
      exit 0
    end

    if options[:local]
      raise MissingFlagError 'Missing key name' unless options[:key] != ''

      key = Key.list.find { |k| k.name == options[:key] }
      local_setup(key)
      exit 0
    end

    file_key = File.read("#{Dir.pwd}/.pgit")
    splitted_key = file_key.split('$')

    raise InvalidKeyError unless splitted_key.length == 3

    key = Key.with_default_path(splitted_key[1], splitted_key[2])
    run(key, ARGV)
  end

  def self.run(key, git_cmd)
    raise InvalidKeyError unless key.exists?

    cmd = ssh_agent_cmd(key, git_cmd)
    stdout, stderr, status = Open3.capture3(cmd)

    raise CMDError.new(stderr) unless status == 0

    print_lines(stdout)
  end

  def self.local_setup(key)
    File.open("#{Dir.pwd}/.pgit", 'w') { |file| file.write(key.dump) }
  end

  def self.ssh_agent_cmd(key, git_cmd)
    "ssh-agent bash -c 'ssh-add #{key.path}/#{key.name}; git #{git_cmd.join(' ')}'"
  end

  def self.print_lines(stdout)
    stdout.split("\n").each do |out|
      print_line(out)
    end
  end

  def self.print_line(line)
    case
    when line.include?('new file:')
      puts line.light_green
    when line.include?('modified:')
      puts line.yellow
    when line.include?('deleted:')
      puts line.light_red
    else
      puts line
    end
  end

  def self.parse
    options = {
      new: false,
      email: '',
      name: '',
      list: false,
      local: false,
      key: '',
      init: false,
    }

    OptionParser.new do |opt|
      opt.on('--init') { |_| options[:init] = true }
      opt.on('-n') { |_| options[:new] = true }
      opt.on('--email EMAIL') { |email| options[:email] = email }
      opt.on('--name NAME') { |name| options[:name] = name }
      opt.on('-ls') { |_| options[:list] = true }
      opt.on('--local') { |_| options[:local] = true }
      opt.on('-k KEY', '--key KEY') { |key| options[:key] = key }
    end.parse!

    options
  end
end
