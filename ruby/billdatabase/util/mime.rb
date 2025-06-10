require 'json'

# WIP
module Mime
  def TypeFor(extension)
    puts 'extension = ' << extension
    case extension
    when /.jpe?g$/
      'image/jpeg'
    when /.gif$/
      'image/gif'
    when /.pdf$/
      'application/pdf'
    when /.txt$/
      'text/plain'
    else
      'text/html'
    end
  end
end
