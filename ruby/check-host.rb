# frozen_string_literal: true
# ddclient-like checker.
# If your host foohost.co.uk sits here, run this ruby script and it will alert you
# if the host in the unbound.conf (e.g. foohost.co.uk 1.2.3.4) is set
# differently from what the ip checker thinks your ip is.

require 'uri'
require 'json'
require 'net/http'
require 'optparse'

# parse options.
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: check-host.rb --host your.host.name --keyfile api.key.file [ --debug ]'
  options[:live] = true
  opts.on('-d', '--debug', 'Output more information') do
    options[:debug] = true
  end
  opts.on('-k', '--key-file FILE', 'Specify the api key file') do |keyfile|
    options[:apikeyfile] = keyfile
  end
  opts.on('-f', '--fake-response FILE', 'Specify fake response file instead of doing a live call') do |fakefile|
    options[:fakefile] = fakefile
    options[:live] = false
  end
  opts.on('-o', '--host HOST', 'Specify the host for lookup') do |host|
    options[:host] = host
  end
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end.parse!

puts options
DO_LIVE_CALL = options[:live]
DEBUG = options[:debug]
# e.g. '/home/colin/code/src/ruby/sample-ipapi-response.txt'
FAKE_RESPONSE_FILE = options[:fakefile]
# e.g. '/home/colin/code/src/ruby/ipapi-key.txt'
APIKEYFILE = options[:apikeyfile]
CHECKERNAME = 'ipapi.com'
IPCHECKER = 'http://api.ipapi.com/api/check?access_key='
# location of your unbound dns conf file
UNBOUNDCONF = '/usr/local/etc/unbound/unbound.conf'
# your host e.g. 'google.com'
HOSTN = options[:host]

# Check we have the necessary stuff
if HOSTN.nil?
  puts 'host was not provided!'
  exit
end
if APIKEYFILE.nil?
  puts 'key-file not provided'
  exit
else
  unless File.exist?(APIKEYFILE)
    puts 'given key file does not exist'
    exit
  end
end
if !DO_LIVE_CALL && !File.exist?(FAKE_RESPONSE_FILE)
  puts 'given response file does not exist'
  exit
end

ip = nil
File.read(UNBOUNDCONF).lines.each do |line|
  ip = Regexp.last_match(1) if /(\d+\.\d+\.\d+\.\d+) (#{HOSTN})/ =~ line
end

if ip.nil?
  puts "Couldn't find ip in the config file" if DEBUG
elsif DEBUG
  puts "Unbound config file says your (#{HOSTN}) IP is: #{ip}"
end

# we can only do a fixed # of calls per month
# so for debugging we have a pre-made string
# See https://ipapi.com/documentation for response structure.
checkipresponse = nil
if DO_LIVE_CALL
  # need the api key. i've kept it in ipapi-key.txt for simplicity
  apikey = File.open(APIKEYFILE).read
  puts "api key is #{apikey}" if DEBUG
  res = Net::HTTP.get_response(URI("#{IPCHECKER}#{apikey}"))
  if res.is_a?(Net::HTTPSuccess)
    response = JSON.parse(res.body)
    checkipresponse = response['ip']
  else
    puts 'Unsuccessful response from ip checker:'
    puts res
  end
else
  puts 'Not doing a live call on request.' if DEBUG
  response = JSON.parse(File.open(FAKE_RESPONSE_FILE).read)
  checkipresponse = response['ip']
end
puts "IP Checker says your IP is: #{checkipresponse}" if DEBUG

if checkipresponse != ip
  puts "For #{HOSTN},"
  puts "    IP Checker (#{CHECKERNAME}) ip = #{checkipresponse}"
  puts "    Unbound config file ip = #{ip} \n\n"
  puts 'Please correct the config ASAP.'
elsif DEBUG
  puts "IPs match so you're grand."
end
