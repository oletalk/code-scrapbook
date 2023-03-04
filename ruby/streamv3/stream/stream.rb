# frozen_string_literal: true

# require 'iostreams'

# A class for handling streaming from a file
class SongStream
  def initialize(filename)
    # @file = IOStreams.path(filename)
    @file = filename
  end

  def readall
    f = File.open(@file, "rb")
    f.read
  end
  
end
