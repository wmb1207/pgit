# frozen_string_literal: true

require_relative 'pgit/config'
require_relative 'pgit/runner'

# Entrypoint
module Pgit
  def self.run
    # Config.default_cfg
    CLI.main
  end
end
