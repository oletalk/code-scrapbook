require_relative '../../streamserver/data/songcache'


module Cacheable

  @@cache = SongCache.new(capacity: 10)

  def do_cached(hash)
    ret = nil
    cached_val = @@cache.fetch(hash)
    if @@cache.fetch(hash) == nil
      Log.log.info "cache miss: #{hash}"
      p "cache miss: #{hash}"
      @@cache.store(hash, yield)
      ret = @@cache.fetch(hash)
    else
      Log.log.info "cache hit: #{hash}"
      p "cache hit: #{hash}"
      ret = cached_val
    end
    ret
  end

end
