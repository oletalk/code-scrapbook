# frozen_string_literal: true

require_relative '../sendertag'
require_relative 'basemapper'

# class to assist in creating objects from a db result/result row
class SenderTagMapper < BaseMapper
  def create_from_row(result_row)
    SenderTag.new(result_row['tag_id'], result_row['tag_name'])
  end
end
