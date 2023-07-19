# frozen_string_literal: true

require 'ipaddr'
require_relative 'clients'

# An IP whitelist for allowing access to the stream server
class IPWhitelist
  def initialize(iplist, default)
    @list = iplist # see clients.rb for expected structure
    @deflt = default
  end

  def action(clientip)
    ret = @deflt
    cip = IPAddr.new(clientip)
    # check for first matching value
    @list.each do |ip, action|
      listip = IPAddr.new(ip)
      if listip.include?(cip)
        ret = action
        break
      end
    end
    # return hash with action and whether to downsample or not
    ret[:downsample] = false if ret[:allow] && !ret.key?(:downsample)

    ret
  end
end
