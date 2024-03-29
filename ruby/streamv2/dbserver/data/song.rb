# frozen_string_literal: true

# Class for song metadata
class Song
  attr_reader :location, :artist, :title

  def initialize(songrow)
    @location = songrow[:song_filepath]
    @artist = songrow[:artist]
    @title = songrow[:title]
  end
end
