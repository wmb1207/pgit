# frozen_string_literal: true

require_relative "lib/pgit/version"

Gem::Specification.new do |spec|
  spec.name = "pgit"
  spec.version = Pgit::VERSION
  spec.authors = ["wmb"]
  spec.email = ["wenceslao1207@protonmail.com"]

  spec.summary = "Just a simple tool to let me don't think about handling multiple ssh keys while working with multiple github accounts."
  spec.description = "Don't think about your keys, just use the name and the git command you want to run."
  spec.homepage = "https://github.com/wmb1207/pgit"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wmb1207/pgit"
  spec.metadata["changelog_uri"] = "https://github.com/wmb1207/pgit"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "bin"
  spec.executables = ['pgit']
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
