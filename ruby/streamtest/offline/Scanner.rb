require 'mp3info'
require 'optparse'
require 'digest/sha1'

require_relative '../util/db.rb'
require_relative '../util/config.rb'

FILESPEC = "*.{M,m}{P,p}3"
# Scanner.rb

def tag_file_with_hash(mp3file, hash)
    puts "  >>> Getting tag info for file '#{mp3file}'"
    mp3info = Mp3Info.open(mp3file)

    # save mp3info.tag.artist, mp3info.tag.title, mp3info.length
    tag = { artist: mp3info.tag.artist, title: mp3info.tag.title, secs: mp3info.length }
    write_tag(hash, mp3file, tag)
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
files = Dir.glob(rootdir + "/" + FILESPEC )

if files.size == 0
    raise "No files found in given root dir #{rootdir}" 
end

files.each do |f|
    # check the db for the tag
    # TODO: should probably only compute the hash in a 'long' version - check args
    file_hash = Digest::SHA1.hexdigest(f)
    tag = get_tag_for(file_hash, f)
    # either 1. tag exists and has data, 2. tag exists but has nils or 3. tag is nil (no record found)
    if tag.nil?
        puts "Need to find the tag for file: " + f
        # compute and write the tag!
        tag_file_with_hash(f, file_hash)
    end
end
