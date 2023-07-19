# frozen_string_literal: true

require 'open3'
require_relative '../constants'

class Player
  def play_downsampled(song)

    command = nil
    case song
    when /mp3$/i
      command = MP3S::Config::Play::DOWNSAMPLED_MP3
    when /ogg$/i
      command = MP3S::Config::Play::DOWNSAMPLED_OGG
    else
      # TODO: log this
      puts "No idea how to downsample this song!"
    end

    escaped = +song
    escaped.gsub!(/"/, %q(\\\"))
    arg_song = %("#{escaped}")
    time_start = Time.now
    cmdexec = command.sub(/XXXX/, arg_song)
    # TODO: setup logging...
    stdout, stderr, status = Open3.capture3(cmdexec.to_s, binmode: true)
    time_end_downsample = Time.now
    puts "Downsampling completed in #{time_end_downsample - time_start} seconds."
    puts stderr unless stderr.to_s.strip.empty?

    stdout
  end
end

