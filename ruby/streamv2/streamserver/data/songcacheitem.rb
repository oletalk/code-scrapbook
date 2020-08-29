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
    if songdata_trunc.length > 40
      songdata_trunc = "*binary data* #{@songdata.length} bytes"
    end
    "songdata: #{songdata_trunc}, ts: #{@ts}"
  end
end
