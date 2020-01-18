#\ -p 2351 -o 0.0.0.0 -q
require './DBServer'
#require 'rack/cache'

#use Rack::Cache,
#    :metastore => 'file:/var/tmp/rack/meta',
#    :entitystore => 'file:/var/tmp/rack/body',
#    :verbose => true

run DBServer
