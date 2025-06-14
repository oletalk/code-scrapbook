require 'json'

# WIP
module Mime
  def TypeFor(extension)
    case extension
    when /.jpe?g$/
      'image/jpeg'
    when /.gif$/
      'image/gif'
    when /.pdf$/
      'application/pdf'
    when /.zip$/
      'application/x-zip'
    when /.txt$/
      'text/plain'
    else
      'text/html'
    end
  end
end
