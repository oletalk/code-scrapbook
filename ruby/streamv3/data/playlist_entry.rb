# frozen_string_literal: true

# holds information about a playlist entry
class PLEntry
  attr_reader :title,
              :url,
              :secs

  def initialize(titl, url, secns)
    @title = titl
    @url = url
    @secs = secns
  end
end
