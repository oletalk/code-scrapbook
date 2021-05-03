# frozen_string_literal: true

class SongCacheItem
  attr_reader :songdata, :ts

  def initialize(songdata)
    @songdata = songdata
    @ts = Time.new
  end

  def update
    @ts = Time.new
  end

  def inspect
    songdata_trunc = @songdata
    songdata_trunc = "*binary data* #{@songdata.length} bytes" if songdata_trunc.length > 40
    "songdata: #{songdata_trunc}, ts: #{@ts}"
  end
end
