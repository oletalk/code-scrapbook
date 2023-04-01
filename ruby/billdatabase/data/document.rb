# frozen_string_literal: true

require_relative 'doctype'
require_relative 'sender'
require_relative 'senderaccount'

# holds information about a document
class Document
  attr_reader :id, :created_at, :received_date, :doc_type, :sender
  attr_accessor :due_date, :paid_date, :file_location, :comments, :sender_account

  def initialize(_id_, _created_at_, _received_date_, doc_type_, sender_)
    raise TypeError, 'Argument #4 should be a DocType object' unless doc_type_.is_a?(DocType)
    raise TypeError, 'Argument #5 should be a Sender object' unless sender_.is_a?(Sender)
  end
end
