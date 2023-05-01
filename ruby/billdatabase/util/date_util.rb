# frozen_string_literal: true

require 'date'

# date checking utility functions
module DateUtil
  def check_ymd(date_string)
    y, m, d = date_string.split '-'
    Date.valid_date? y.to_i, m.to_i, d.to_i
  end
end
