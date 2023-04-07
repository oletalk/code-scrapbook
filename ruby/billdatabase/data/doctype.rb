# frozen_string_literal: true

require 'json'

# holds information about a document type (invoice, statement, notice etc)
class DocType
  attr_reader :id, :name

  def initialize(id_, name_)
    @id = id_
    @name = name_
  end

  def to_json(*args)
    {
      JSON.create_id => self.class.name,
      'id' => @id,
      'name' => @name
    }.to_json(*args)
  end
end
