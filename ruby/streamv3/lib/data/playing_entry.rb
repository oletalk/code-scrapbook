# frozen_string_literal: true

# entry in NowPlaying list (by ip)
class PlayingEntry
  def initialize(hsong, endtime)
    raise 'PlayingEntry was not given a HashSong' unless hsong.is_a?(HashSong)

    @hash_song = hsong
    @end_time = endtime
  end

  attr_reader :hash_song

  def elapsed?
    @end_time < Time.now
  end
end
