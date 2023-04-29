# frozen_string_literal: true

# base class to assist in creating objects from a db result/result row
# Generic because klass is a component class e.g. SenderAccount, SenderTag
#   - the component class should:
#      1. have a 'fill_out_from' method from a database row, and
#      2. have a constructor taking an id and sender_id (ints)
class GenericMapper
  def create_from_result(result, klass)
    ret = []
    result.each do |result_row|
      ret.push(create_from_row(result_row, klass))
    end

    ret
  end

  def create_from_row(result_row, klass)
    ret = klass.new(result_row['id'], result_row['sender_id'])
    ret.fill_out_from(result_row)
    ret
  end
end
