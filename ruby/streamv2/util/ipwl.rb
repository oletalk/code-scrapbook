require 'ipaddr'
require_relative 'clients'

class IPWhitelist

    def initialize(iplist, default)
        @list = iplist #see clients.rb for expected structure
        @deflt = default
    end

    def action(clientip)
        ret = @deflt
        cip = IPAddr.new(clientip)
        # check for first matching value
        @list.each { |ip,action|
            listip = IPAddr.new(ip)
            if listip.include?(cip)
                ret = action
                break
            end
        }
        # return hash with action and whether to downsample or not
        if ret[:allow] && !ret.key?(:downsample)
            ret[:downsample] = false
        end

        ret
    end
end
