# frozen_string_literal: true

# holds information about each account you have with an entity (e.g. bank account with barclays)
class SenderAccount
  attr_reader :id, :sender_id
  attr_accessor :account_number, :account_details, :comments

  def initialize(id_, sender_id_)
    @id = id_
    @sender_id = sender_id_
  end

  def fill_out_from(result_row)
    @account_number = result_row['account_number']
    @account_details = result_row['account_details']
    @comments = result_row['comments']
  end
end
