require 'mp3info'
require 'optparse'
require 'digest/sha1'

require_relative '../util/db.rb'
require_relative '../util/config.rb'

#FILESPEC = "*.{M,m}{P,p}3"
FILESPEC = "*.mp3"
#FILESPEC = "*.ogg"
# Scanner.rb

$db = Db.new

def tag_file_with_hash(mp3file, hash)
    puts "  >>> Getting tag info for file '#{mp3file}'"
    begin
        mp3info = Mp3Info.open(mp3file)
        songlen = mp3info.length
        songlen = if songlen.nil? then -1 else songlen.floor end

        # save mp3info.tag.artist, mp3info.tag.title, mp3info.length
        tag = { artist: mp3info.tag.artist, title: mp3info.tag.title, secs: songlen }
        $db.write_tag(hash, mp3file, tag)
    rescue
        puts "Unable to read tag in file! Skipping..."
    end
end

# Options
options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: Scanner.rb [options]"

    opts.on('-l', '--long', 'Long process, check ALL files in directory for tags') { options[:long] = true }
    opts.on('-rDIR', '--rootdir=DIR', 'Specify the root directory') { |v| options[:rootdir] = v }
end.parse!

# Recurse through directory and check database for any files that are missing tags
# Try to tag these files
#    - for any file that didn't have a tag, and still doesn't have one, record this somewhere(??)
rootdir = options[:rootdir] || MP3S::Config::MP3_ROOT
rootdir.sub!(/\/$/, '')  # no trailing slash pls
puts "Scanning through given base directory #{rootdir}"
files = Dir.glob(rootdir + "/**/" + FILESPEC )

puts "Filespec was '#{rootdir + "/**/" + FILESPEC}' files"
if files.size == 0
    raise "No files found in given root dir #{rootdir}" 
end

puts "Files found in directory: #{files.size}"
files.each do |f|
    safe_filename = f
    begin
        safe_filename.encode!('utf-8')
    rescue
        puts "UTF-8 error with #{f}! Skipping :-( "
        next
    end
    # check the db for the tag
    # TODO: should probably only compute the hash in a 'long' version - check args
    file_hash = Digest::SHA1.hexdigest(safe_filename)
    tag = $db.get_tag_for(file_hash, safe_filename)
    # either 1. tag exists and has data, 2. tag exists but has nils or 3. tag is nil (no record found)
    if tag.nil?
        puts "Need to find the tag for file: " + safe_filename
        # compute and write the tag!
        tag_file_with_hash(safe_filename, file_hash)
    end
end
