# # frozen_string_literal: true

require_relative '../common/logging'
require_relative '../stream/sftpget'
require_relative '../constants.rb'
require_relative '../db/db.rb'

class StartupCheck
  include Logging
  include SftpGet
  include Db

  def initialize
    logger.info('doing startup checks ...')
    begin
      check_cache_directory
      check_play_commands
      check_sftp
      check_db
    rescue StandardError => e
      puts '### STARTUP CHECKS FAILED ###'
      puts "Details: #{e.message}"
      exit(false)
    end
  end

  def check_cache_directory
    raise 'Cache directory does not exist' unless File.directory?(MP3S::Config::Cache::TEMP_ROOT)
    logger.info('cache directory exists')
  end

  def check_play_commands
    raise 'MP3 downsampling command does not exist' unless File.executable?(MP3S::Config::Play::LAME_CMD)
    raise 'OGG downsampling command does not exist' unless File.executable?(MP3S::Config::Play::SOX_CMD)
    logger.info('downsampling commands exist and are executable')
  end

end
