require 'json'
    
module Format
    def self.html_list(songlist)
        ret = songlist.collect{ |song| 
            %{ <a href='/play/#{song[:hash]}'>#{song[:title]}</a> }
        }.join("<br/>\n")
        ret
    end

    def self.json_list(songlist)
        songlist.to_json
    end

    def self.play_list(songlist, hdr_http_host)
        ret = "#EXTM3U\n"
        ret << songlist.collect{ |song|
            "#EXTINF:#{song[:secs]},#{song[:title]}\n" +
            "http://#{hdr_http_host}/play/#{song[:hash]}"
        }.join("\n")
    end
end
