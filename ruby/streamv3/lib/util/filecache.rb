# frozen_string_literal: true

# require 'ipaddr'
require 'digest/sha1'
require_relative '../constants'
require_relative '../common/logging'
require_relative '../stream/sftpget'

# util cache to manage the size of the cache directory we dump files into
class FileCache
  include Logging
  include SftpGet

  def initialize
    @fileroot = MP3S::Config::Cache::TEMP_ROOT
    @max_size = sizeparse(MP3S::Config::Cache::MAX_SIZE)
    @next_check = Time.now + MP3S::Config::Cache::CACHE_INTERVAL_SECS
    logger.debug "Song cache max size set to #{@max_size} bytes."
    logger.debug "Next check will be at #{@next_check}."
  end

  def do_periodic_check
    # is it time to check?
    return unless Time.now > @next_check

    maintain_cache_size
    @next_check = Time.now + MP3S::Config::Cache::CACHE_INTERVAL_SECS
  end

  def get_cached_content(ftpfile)
    # filename will be of the form b1c2a6_MyCoolSong.mp3
    dirhash = Digest::SHA1.hexdigest(File.dirname(ftpfile))
    hash_pre = dirhash[-6..]
    tempfile = "#{@fileroot}/#{hash_pre}_#{File.basename(ftpfile)}"
    if File.exist?(tempfile)
      logger.info 'we already have cached file'
      f = File.open(tempfile)
      f.read
    else
      logger.info "#{tempfile} not found. downloading and downsampling."
      sftpget(ftpfile, tempfile)

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
    curr_size = current_cache_size
    return unless curr_size > @max_size

    logger.warn "Cache size = #{curr_size}, maximum size = #{@max_size}"
    logger.warn 'Cache exceeded maximum size... time to trim it'
    while curr_size > @max_size
      delfile = oldest_filename
      exit_code = system "rm #{Shellwords.escape(delfile)}"
      raise 'unable to trim cache file' unless exit_code

      curr_size = current_cache_size
      logger.debug "new cache size is #{curr_size}"
      sleep 0.3
    end
  end

  def current_cache_size
    rootfiles = "#{MP3S::Config::Cache::TEMP_ROOT}/*"
    Dir[rootfiles].select { |f| File.file?(f) }.sum { |f| File.size(f) }
  end

  def oldest_filename
    (Dir["#{@fileroot}/*"]).min_by { |f| File.mtime(f) }
  end
end
