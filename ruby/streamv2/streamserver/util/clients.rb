# frozen_string_literal: true

module MP3S
  module Clients
    # list your ips/ip ranges and specify :allow or :deny
    # if :allow, next item is :downsample or :nodownsample
    # if neither is given we assume the defaults at the bottom

    List = {
      '192.168.0.0/24' => {
        allow: true,
        downsample: false,
        playlist: true
      },
      '109.148.232.0/24' => { allow: true, downsample: true },
      '82.118.92.0/24' => { allow: true, downsample: true },
      '130.209.164.0/24' => { allow: true, downsample: true },
      '130.209.6.0/24' => { allow: true, downsample: true }
    }.freeze

    Default = { allow: false, playlist: false }.freeze
  end
end
