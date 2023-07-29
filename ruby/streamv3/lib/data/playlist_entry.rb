# frozen_string_literal: true

require 'json'

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

  def as_json(_options={})
    {
      title: @title,
      url: @url,
      secs: @secs
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
