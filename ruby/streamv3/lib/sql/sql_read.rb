# frozen_string_literal: true

# file to separate out the file reading bit in classes
# for testability of the rest of the class
module SqlRead
  def sqlfrom(sqlname)
    File.read("./sql/#{sqlname}.sql")
  end
end
