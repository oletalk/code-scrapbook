# frozen_string_literal: true

require 'open3'
require_relative '../../common/util/config'
require_relative '../../common/util/logging'
require_relative '../data/played'

# Class to handle streaming or compressing of an MP3 or OGG file.
class Player
  def songresponse(_req_hash, song_loc, downsample = false)
    # play it (stream server will be calling this method)
    command = get_command(downsample, song_loc)
    Log.log.info("Fetched command template, #{command}")

    played = play_song(command, song_loc)
    w = played.warnings
    Log.log.warn(w) unless w.nil? || (w == '')
    played.songdata
  end

  def play_song(command, song)
    escaped = +song
    escaped.gsub!(/"/, %q(\\\"))
    arg_song = %("#{escaped}")

    cmdexec = command.sub(/XXXX/, arg_song)
    Log.log.info("Command to send: #{cmdexec}")
    stdout, stderr, status = Open3.capture3(cmdexec.to_s, binmode: true)
    Log.log.info("return status: #{status}, stdout.length = #{stdout.length}, stderr.length = #{stderr.length}")
    puts stderr unless stderr.to_s.strip.empty?
    Played.new(stdout, cmdexec, stderr)
  end

  def get_command(downsample, song)
    if downsample
      # check if downsampling mp3/ogg
      case song
      when /mp3$/i
        command = MP3S::Config::Play::DOWNSAMPLED_MP3
      when /ogg$/i
        command = MP3S::Config::Play::DOWNSAMPLED_OGG
      else
        Log.log.error("No idea how to downsample given file type #{song}")
        command = nil
      end
    else
      command = MP3S::Config::Play::RAW
    end
    command
  end
end
