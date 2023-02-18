# frozen_string_literal: true

require 'iostreams'

# A class for handling streaming from a file
class Stream
  def initialize(filename)
    @file = IOStreams.path(filename)
  end

  def readall
    ret = ''.dup
    @file.reader do |io|
      while (data = io.read(128))
        ret << data
      end
    end
  end
end
