# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

DO_LIVE_CALL = false
DEBUG = false
FAKE_RESPONSE_FILE = '/home/colin/code/src/ruby/sample-ipapi-response.txt'
APIKEYFILE = '/home/colin/code/src/ruby/ipapi-key.txt'
CHECKERNAME = 'ipapi.com'
IPCHECKER = 'http://api.ipapi.com/api/check?access_key='
UNBOUNDCONF = '/usr/local/etc/unbound/unbound.conf'
HOSTN = 'maughan.homelinux.net'
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
