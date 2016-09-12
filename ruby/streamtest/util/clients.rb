module MP3S
    module Clients
        # list your ips/ip ranges and specify :allow or :deny
        # if :allow, next item is :downsample or :nodownsample
        # if neither is given we assume the defaults at the bottom

        List = { '192.168.0.0/24' => { allow: true, downsample: true } }
        Default = { allow: false }
    end
end
