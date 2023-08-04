# frozen_string_literal: true

require 'logger'

# module for logging
module Logging
  def logger
    Logging.logger
  end

  def self.logger
    @logger = Logger.new($stdout)

    @logger.formatter = proc { |severity, datetime, _procname, msg|
      sev = format('%-6s', severity)
      "#{sev} #{datetime} #{msg}\n"
    }
    @logger
  end
end
