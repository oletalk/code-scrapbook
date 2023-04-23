# frozen_string_literal: true

require 'json'

# holds information about each account you have with an entity (e.g. bank account with barclays)
class SenderContact
  attr_reader :id
  attr_accessor :name, :contact, :comments

  def initialize(id_)
    @id = id_
  end

  def fill_out_from(result_row)
    @name = result_row['name']
    @contact = result_row['contact']
    @comments = result_row['comments']
  end

  def to_json(*args)
    {
      JSON.create_id => self.class.name,
      'id' => @id,
      'name' => @name,
      'contact' => @contact,
      'comments' => @comments
    }.to_json(*args)
  end
end
