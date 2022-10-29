# frozen_string_literal: true

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
end
