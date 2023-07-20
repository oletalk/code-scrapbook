# frozen_string_literal: true

# module for logging
module Logging
  def logger
    Logging.logger
  end

  def self.logger
    @logger ||= Logger.new($stdout)
  end
end
