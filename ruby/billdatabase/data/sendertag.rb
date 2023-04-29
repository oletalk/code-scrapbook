# frozen_string_literal: true

require 'json'

# holds information about each account you have with an entity (e.g. bank account with barclays)
class SenderTag
  attr_reader :id, :description

  def initialize(id_, description_)
    @id = id_
    @description = description_
  end

  def to_json(*args)
    {
      JSON.create_id => self.class.name,
      'id' => @id,
      'description' => @description
    }.to_json(*args)
  end
end
