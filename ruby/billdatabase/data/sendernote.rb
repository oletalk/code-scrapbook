# frozen_string_literal: true

require 'json'

# holds any notes you have made about an entity (e.g. when you closed an account)
class SenderNote
  attr_reader :id, :sender_id
  attr_accessor :notes, :created_at

  def initialize(id_, sender_id_)
    @id = id_
    @sender_id = sender_id_
  end

  def fill_out_from(result_row)
    @created_at = result_row['created_at']
    @notes = result_row['notes']
  end

  def to_json(*args)
    {
      JSON.create_id => self.class.name,
      'id' => @id,
      'sender_id' => @sender_id,
      'created_at' => @created_at,
      'notes' => @notes
    }.to_json(*args)
  end
end
