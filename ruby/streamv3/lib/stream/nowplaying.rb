# frozen_string_literal: true

require_relative '../db/hashsong'
require_relative '../common/logging'

# stats to show on members page
class NowPlaying
  include Logging

  def initialize
    @curr_playing = nil
    @end_time = Time.now
  end

  def playing
    @curr_playing = nil if @end_time < Time.now
    @curr_playing&.display_title
  end

  def start(hsong)
    raise 'NowPlaying.start was not passed a HashSong' unless hsong.is_a?(HashSong)

    unless @curr_playing.nil? || Time.now < @end_time
      # if it IS true that @curr_playing is not nil AND Time.now is past @end_time
      logger.debug 'Song duration has elapsed'
      logger.debug 'Recording song played'
      @curr_playing.record_stat
    end
    logger.debug 'Recording start of play'
    @curr_playing = hsong
    @end_time = Time.now + (hsong.secs.nil? ? 0 : hsong.secs.to_i)
  end
end
