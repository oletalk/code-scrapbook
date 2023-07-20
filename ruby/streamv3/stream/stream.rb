# frozen_string_literal: true

require_relative '../constants'
require_relative './player'

# A class for handling streaming from a file
class SongStream
  def initialize(filename)
    @file = filename
  end

  def readall(cache)
    ftpfile = @file.sub(%r{/opt/gulfport}, '/rockport')
    c = cache # FileCache.new
    c.do_periodic_check
    c.get_cached_content(ftpfile)
  end
end
