# frozen_string_literal: true

require_relative 'senderaccount'

# holds information about the sender of a document (account you have with them)
class Sender
  attr_reader :id, :created_at, :sender_accounts
  attr_accessor :name, :username, :password_hint, :comments

  def initialize(id_, created_at_)
    @id = id_
    @created_at = created_at_
    @sender_accounts = []
  end

  def fill_out_from(result_row)
    @name = result_row['name']
    @username = result_row['username']
    @password_hint = result_row['password_hint']
    @comments = result_row['comments']
  end

  def add_accounts(accounts)
    accounts.each do |account|
      raise "Array doesn't completely consist of SenderAccounts" \
      unless account.is_a?(SenderAccount)

      @sender_accounts.push(account)
    end
  end
end
