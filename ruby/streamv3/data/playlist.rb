# frozen_string_literal: true

require 'json'

# holds information about a user of the management gui
class NamedPlaylist
  attr_reader :name,
              :owner,
              :date_created,
              :date_modified

  def initialize(nme, ownr, created, modified)
    @name = nme
    @owner = ownr
    @date_created = created
    @date_modified = modified
  end

  def as_json(_options={})
    {
      name: @name,
      owner: @owner,
      date_created: @date_created,
      date_modified: @date_modified
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
