# frozen_string_literal: true

require 'ipaddr'
require 'net/sftp'
require_relative '../constants'
require_relative '../common/logging'

# util cache to manage the size of the cache directory we dump files into
class FileCache
  include Logging
  def initialize
    @fileroot = MP3S::Config::Cache::TEMP_ROOT
    @max_size = sizeparse(MP3S::Config::Cache::MAX_SIZE)
    @next_check = Time.now + MP3S::Config::Cache::CACHE_INTERVAL_SECS
    logger.debug "Song cache max size set to #{@max_size} bytes."
    logger.debug "Next check will be at #{@next_check}."
  end

  def do_periodic_check
    # is it time to check?
    if Time.now > @next_check
      maintain_cache_size
      @next_check = Time.now + MP3S::Config::Cache::CACHE_INTERVAL_SECS
    end
  end

  def get_cached_content(ftpfile)
    time_start = Time.now
    tempfile = "#{@fileroot}/#{File.basename(ftpfile)}"
    if File.exist?(tempfile)
      logger.info 'we already have cached file'
      f = File.open(tempfile)
      f.read
    else
      logger.info "#{tempfile} not found. downloading and downsampling."
      sftp = Net::SFTP.start(
        MP3S::Config::Sftp::SERVER_HOST, MP3S::Config::Sftp::USER,
        password: MP3S::Config::Sftp::PASSWORD
      )

      # f = File.open(@file, "rb")
      sftp.download!(ftpfile, tempfile) do |event, downloader, *args|
        case event
        when :open then
          logger.debug "  ## starting download from #{args[0].remote}"
        # when :get then <-- further detail, progress
        when :close then
          logger.debug "  ## finished with #{args[0].remote}"
        when :finish then
          logger.debug '  ## complete'
        end
      end
      time_end_download = Time.now
      logger.info "Download completed in #{time_end_download - time_start} seconds."

      # TODO: do we want to make downsampling optional?
      p = Player.new
      p.play_downsampled(tempfile)
    end
  end

  def sizeparse(sizestr)
    ret = 20_000 # failsafe?
    m = sizestr.match(/^\d+/)
    unless m.nil?
      ret = Integer(m[0])
      case sizestr[-1]
      when 'M'
        ret *= 1_048_576
      when 'G'
        ret *= 1_073_741_824
      else
        raise 'Unknown cache size unit'
      end
    end
    ret
  end

  def maintain_cache_size
    curr_size = Dir['/var/tmp/files/*'].select { |f| File.file?(f) }.sum { |f| File.size(f) }
    return unless curr_size > @max_size

    logger.warn "Cache size = #{curr_size}, maximum size = #{@max_size}"
    logger.warn 'Cache exceeded maximum size... time to trim it'
    while curr_size > @max_size
      delfile = oldest_filename
      exit_code = system "rm #{Shellwords.escape(delfile)}"
      raise 'unable to trim cache file' unless exit_code

      curr_size = Dir['/var/tmp/files/*'].select { |f| File.file?(f) }.sum { |f| File.size(f) }
      logger.debug "new cache size is #{curr_size}"
      sleep 0.3
    end
  end

  def oldest_filename
    (Dir["#{@fileroot}/*"]).min_by { |f| File.mtime(f) }
  end
end
