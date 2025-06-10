require 'json'

# WIP
module Mime
  def TypeFor(extension)
    if extension =~ /.jpg$/
      'image/jpeg'
    elsif extension =~ /.gif$/
      'image/gif'
    elsif extension =~ /.pdf$/
      'application/pdf'
    else
      'text/html'
    end
  end
end
