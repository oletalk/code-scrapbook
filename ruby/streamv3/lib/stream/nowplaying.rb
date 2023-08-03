# frozen_string_literal: true

require_relative '../db/hashsong'
require_relative '../common/logging'

# stats to show on members page
class NowPlaying
  include Logging

  def initialize
    @curr_playing = {}
    @end_time = {}
  end

  def playing(ip)
    @curr_playing[ip] = nil if @end_time.key?(ip) && @end_time[ip] < Time.now
    @curr_playing[ip]&.display_title
  end

  def start(hsong, ip)
    raise 'NowPlaying.start was not passed a HashSong' unless hsong.is_a?(HashSong)

    unless @curr_playing.nil? || Time.now < @end_time
      # if it IS true that @curr_playing is not nil AND Time.now is past @end_time
      # should we log if (we think) the next song was started
      # before the previous one elapsed?
      logger.debug 'Song duration has elapsed'
      logger.debug 'Recording song played'
      @curr_playing.record_stat
    end
    logger.debug "Recording start of play for song #{hsong.display_title} at #{ip}"
    @curr_playing[ip] = hsong
    @end_time[ip] = Time.now + (hsong.secs.nil? ? 0 : hsong.secs.to_i)
  end
end
