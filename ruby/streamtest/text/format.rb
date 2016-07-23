require 'json'
    
module Format
    def self.html_list(songlist)
        ret = songlist.collect{ |song| 
            %{ <a href='/play/#{song[:hash]}'>#{song[:title]}</a> }
        }.join("<br/>\n")
        ret
    end

    def self.json_list(songlist)
        retjson = "{}"
        encfailed = false
        begin
            safesonglist = songlist.map{ |foo| 
                { title: foo[:title].encode('UTF-8', {
                    :invalid => :replace,
                    :undef   => :replace,
                    :replace => '?'
                }), 
                  hash: foo[:hash] }
            }
            retjson = safesonglist.to_json
        rescue Encoding::UndefinedConversionError
            encfailed = true
            puts $!.error_char.dump
            p $!.error_char.encoding
        end
            # TODO: handle encfailed somehow
        retjson
    end

    def self.play_list(songlist, hdr_http_host)
        ret = "#EXTM3U\n"
        ret << songlist.collect{ |song|
            "#EXTINF:#{song[:secs]},#{song[:title]}\n" +
            "http://#{hdr_http_host}/play/#{song[:hash]}"
        }.join("\n")
    end
end
