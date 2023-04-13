# frozen_string_literal: true

require_relative 'doctype'
require_relative 'sender'
require_relative 'senderaccount'

# holds information about a document
class Document
  attr_reader :id, :created_at, :received_date, :doc_type, :sender
  attr_accessor :summary, :due_date, :paid_date, :file_location, :comments, :sender_account

  def initialize(id_, created_at_, received_date_, doc_type_, sender_)
    raise TypeError, 'Argument #4 should be a DocType object' unless doc_type_.is_a?(DocType)
    raise TypeError, 'Argument #5 should be a Sender object' unless sender_.is_a?(Sender)

    @id = id_
    @created_at = created_at_
    @received_date = received_date_
    @doc_type = doc_type_
    @sender = sender_
  end

  def fill_out_from(result_row)
    @due_date = result_row['due_date']
    @paid_date = result_row['paid_date']
    @file_location = result_row['file_location']
    @comments = result_row['comments']
    @summary = result_row['summary']
  end
end
