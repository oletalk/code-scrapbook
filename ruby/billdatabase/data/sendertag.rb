# frozen_string_literal: true

require 'json'

# holds information about each account you have with an entity (e.g. bank account with barclays)
class SenderTag
  attr_reader :id, :description, :color

  def initialize(id_, description_, color_)
    @id = id_
    @description = description_
    @color = color_
  end

  def to_json(*args)
    {
      JSON.create_id => self.class.name,
      'id' => @id,
      'description' => @description,
      'color' => @color
    }.to_json(*args)
  end
end
