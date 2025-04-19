require 'json'

# WIP
module ResponseHelper
  def do_post
    ret = { 'result': 'success' }
    yield ret
    ret.to_json
  end
end
