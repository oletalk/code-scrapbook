# frozen_string_literal: true

require_relative 'songcacheitem'

class SongCache
  def initialize(capacity: 20)
    @capacity = capacity
    @list = {}
  end

  def fill
    @list.size
  end

  def store(hash, songdata)
    # TODO: what if the cache already has an item in the 'hash' bucket?
    # Cacheable doesn't allow that to happen
    @list[hash] = SongCacheItem.new(songdata)
    if @list.size > @capacity
      # find oldest item
      oldest = @list.keys[0]
      @list.each_key do |key|
        oldest = key if @list[key].ts < @list[oldest].ts
      end
      @list.delete(oldest)

    end
  end

  def fetch(hash)
    ret = @list[hash]
    ret&.update
    ret
  end
end
