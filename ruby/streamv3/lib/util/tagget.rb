# frozen_string_literal: true

require 'taglib'
require_relative '../common/logging'

# mixin to separate out SFTP code
class TagGet
  include Logging

  def read(mp3file)
    tag = {}
    begin
      TagLib::FileRef.open(mp3file) do |mp3info|
        unless mp3info.null?
          tag = mp3info.tag
          songlen = mp3info.audio_properties.length_in_seconds
          songlen = songlen.nil? ? -1 : songlen.floor

          safe_artist = tag.artist
          safe_artist = safe_artist[0..99] if safe_artist.length > 100
          tag = { artist: safe_artist, title: tag.title, secs: songlen }
        end
      end
    rescue StandardError => e
      puts "Unable to read tag in file (#{e.message})! Skipping..."
    end
    tag
  end
end
