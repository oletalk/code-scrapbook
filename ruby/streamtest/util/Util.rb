require 'uri'
require './config'

CONTENT_TYPE_MAPPING = {
    'html' => 'text/html',
    'txt' => 'text/plain',
    'png' => 'image/png',
    'jpg' => 'image/jpeg'
}

DEFAULT_CONTENT_TYPE = 'application/octet-stream'

def content_type(path)
    ext = File.extname(path).split(".").last
    CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

def http_method(request_line)
    request_method = request_line.split(" ")[0]
    request_method
end

def requested_file(request_line)
    request_uri = request_line.split(" ")[1]
    path = URI.unescape(URI(request_uri).path)

    clean = []

    parts = path.split("/")

    parts.each do |part|

        next if part.empty? || part == '.'

        part == '..' ? clean.pop : clean << part
    end

    File.join(MP3S::Config::WEB_ROOT, *clean)
end
