# frozen_string_literal: true

require_relative '../document'
require_relative '../doctype'
require_relative '../sender'
require_relative 'basemapper'

# class to assist in creating objects from a db result/result row
# this is only the top level info - there's mappers for the accounts and contact info
class DocumentMapper < BaseMapper
  def create_from_row(result_row)
    dt = DocType.new(result_row['doc_type_id'], result_row['doc_type_name'])
    s = Sender.new(result_row['sender_id'], nil)
    s.name = result_row['sender_name']
    ret = Document.new(
      result_row['id'], nil,
      result_row['received_date'], dt, s
    )
    ret.fill_out_from(result_row)
    if result_row['sender_account_id']
      sa_id = result_row['sender_account_id']
      sa_an = result_row['account_number']
      sa = SenderAccount.new(sa_id, s.id)
      sa.account_number = sa_an
      ret.sender_account = sa
    end
    ret
  end
end
