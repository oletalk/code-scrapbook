# frozen_string_literal: true

require 'logger'

# module for logging
module Logging
  def logger
    Logger.new($stdout) # TODO: - not stdout...
  end

  def log_error(str)
    logger.error(str)
  end

  def log_info(str)
    logger.info(str)
  end

  def log_trace(str)
    logger.trace(str)
  end
end
