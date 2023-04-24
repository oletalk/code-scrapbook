# frozen_string_literal: true

require_relative '../sender'
require_relative 'basemapper'

# class to assist in creating objects from a db result/result row
# this is only the top level info - there's mappers for the accounts and contact info
class SenderMapper < BaseMapper
  def create_from_row(result_row)
    ret = Sender.new(result_row['id'], result_row['created_at'])
    ret.fill_out_from(result_row)
    ret
  end
end
