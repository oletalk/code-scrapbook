# frozen_string_literal: true

# base class to assist in creating objects from a db result/result row
# you should subclass this, but nothing stops you from using it
# because ruby's like that i guess
class BaseMapper
  def create_from_result(result)
    ret = []
    result.each do |result_row|
      ret.push(create_from_row(result_row))
    end

    ret
  end
end
