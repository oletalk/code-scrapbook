# frozen_string_literal: true

require_relative '../db/hashsong'
require_relative '../data/playing_entry'
require_relative '../common/logging'

# WRITE TESTS FOR THIS CLASS!!!
# stats to show on members page
class NowPlaying
  include Logging

  def initialize
    @curr_playing = {} # keyed by ip
  end

  # TODO: playing everywhere in the case of multiple users online

  def playing(ip)
    if @curr_playing.key?(ip) && @curr_playing[ip].elapsed?
      @curr_playing.delete(ip)
      logger.debug 'Past end point of song for this ip'
    end
    ret = nil
    if @curr_playing.key?(ip)
      curr_song = @curr_playing[ip]
      remng = curr_song.end_time - Time.now
      remng = remng.to_i
      remng = 'Unknown' if remng <= 0
      ret = {
        title: curr_song.hash_song.display_title,
        remaining: remng
      }
    end
    ret
  end

  def start(hsong, ip)
    raise 'PlayingEntry was not given a HashSong' unless hsong.is_a?(HashSong)

    if @curr_playing.key?(ip) && @curr_playing[ip].elapsed?
      # should we log if (we think) the next song was started
      # before the previous one elapsed?
      logger.debug 'Previous song duration has elapsed'
      logger.debug 'Recording song played'
      # TODO: let it guess the song duration if it wasn't given any
      @curr_playing[ip].hash_song.record_stat
      @curr_playing.delete(ip)
    end
    logger.debug "Recording start of play for song #{hsong.display_title} at #{ip}"
    finishtime = Time.now + (hsong.secs.nil? ? 0 : hsong.secs.to_i)
    @curr_playing[ip] = PlayingEntry.new(hsong, finishtime)
    logger.debug "Recording end time of song #{hsong.display_title} at #{ip} as #{finishtime}"
  end
end
