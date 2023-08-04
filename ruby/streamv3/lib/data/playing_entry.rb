# frozen_string_literal: true

# entry in NowPlaying list (by ip)
class PlayingEntry
  def initialize(hsong, endtime, user)
    raise 'PlayingEntry was not given a HashSong' unless hsong.is_a?(HashSong)

    @hash_song = hsong
    @end_time = endtime
    @user_name = user
  end

  attr_reader :hash_song, :end_time, :user_name

  def elapsed?
    @end_time < Time.now
  end
end
