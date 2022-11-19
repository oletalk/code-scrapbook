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
        playlist: true,
        listen: true
      },
      '109.148.232.0/24' => { allow: true, downsample: true },
      '130.209.164.0/24' => { allow: true, downsample: true, playlist_ro: true },
      '130.209.6.0/24' => { allow: true, downsample: true, playlist_ro: true },
      '81.98.226.0/24' => { allow: true, downsample: true, playlist_ro: true }
    }.freeze

    Default = { allow: false, playlist: false, playlist_ro: false, listen: false }.freeze
  end
end
