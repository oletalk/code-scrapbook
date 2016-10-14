#\ -p 2345 -o 0.0.0.0 -q
require './StreamApp'
require 'rack/cache'

use Rack::Cache,
    :metastore => 'file:/var/tmp/rack/meta',
    :entitystore => 'file:/var/tmp/rack/body',
    :verbose => true

run StreamApp
