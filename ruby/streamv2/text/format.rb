require 'json'

module Format
    def self.html_list(songlist, downsampled=false)
		ds = ""
		if downsampled
			ds = "/downsampled"
		end
        ret = songlist.collect{ |song|
            %{ <a href='/play/#{song[:hash]}#{ds}'>#{song[:title]}</a> }
        }.join("<br/>\n")
        ret
    end

    def self.display_playlist(input)
      input.to_s
    end

    def self.json(object)
        object.to_json
    end

    def self.json_list(songlist)
        retjson = "{}"
        encfailed = false
        begin
            safesonglist = songlist
                .map{ |e| e[:title].nil? ? {title:'untitled'} : e }
                .map{ |foo|
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

    def self.play_list(songlist, hdr_http_host, downsampled=false)
		ds = ""
		if downsampled
			ds = "/downsampled"
		end
        ret = "#EXTM3U\n"
        ret << songlist.collect{ |song|
            "#EXTINF:#{song[:secs]},#{song[:title]}\n" +
            "http://#{hdr_http_host}/play/#{song[:hash]}#{ds}"
        }.join("\n")
    end
end
