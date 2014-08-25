#!/opt/local/bin/ruby2.1

require 'optparse'
require './activities'  # ruby 1.9 removed current path from load path
options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: log.rb [options]"
  
  opts.on("-d", "--[no-]debug", "Show debugging output") do |d|
    options[:debug] = d
  end
  
end.parse!

# 1st argument is the 'command', rest are the arguments to this command
# e.g. (./log.pl ) start 'make bread' '09:15'

command = ARGV.shift
command_args = ARGV.clone

unless command
  puts "Please supply a command to log.pl"
  abort
end

if options[:debug]
  puts "command is #{command}" 
  p options
  p command_args
end

logger = ActivityLogger.new('test/activities.txt')
case command
when "start"
  logger.start(command_args[0])
else
  puts "Don't know how to handle your '#{command}' command"
end
puts "done"

#'p' is a kernel method that writes out <the object>.inspect
# e.g. p ARGV