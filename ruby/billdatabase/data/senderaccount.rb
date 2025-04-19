# frozen_string_literal: true

require 'json'

# holds information about each account you have with an entity (e.g. bank account with barclays)
class SenderAccount
  attr_reader :id, :sender_id
  attr_accessor :account_number, :account_details, :closed, :comments

  def initialize(id_, sender_id_)
    @id = id_
    @sender_id = sender_id_
  end

  def fill_out_from(result_row)
    @account_number = result_row['account_number']
    @account_details = result_row['account_details']
    @closed = result_row['closed']
    @comments = result_row['comments']
  end

  def to_json(*args)
    {
      JSON.create_id => self.class.name,
      'id' => @id,
      'sender_id' => @sender_id,
      'account_number' => @account_number,
      'account_details' => @account_details,
      'closed' => @closed == 'Y',
      'comments' => @comments
    }.to_json(*args)
  end
end
