# frozen_string_literal: true

require_relative '../sendercontact'
require_relative 'basemapper'

# class to assist in creating objects from a db result/result row
class SenderContactMapper < BaseMapper
  def create_from_row(result_row)
    ret = SenderContact.new(result_row['id'], result_row['sender_id'])
    ret.fill_out_from(result_row)
    ret
  end
end
