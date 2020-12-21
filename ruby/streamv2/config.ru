require './StreamServer'
#require 'rack/cache'

#use Rack::Cache,
#    :metastore => 'file:/var/tmp/rack/meta',
#    :entitystore => 'file:/var/tmp/rack/body',
#    :verbose => true

run StreamServer
