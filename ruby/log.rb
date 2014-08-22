#!/opt/local/bin/ruby2.1

require 'optparse'

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

#'p' is a kernel method that writes out <the object>.inspect
# e.g. p ARGV