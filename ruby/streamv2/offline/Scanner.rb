# frozen_string_literal: true

require 'taglib' # should do mp3s and oggs
require 'optparse'
require 'digest/sha1'

require_relative '../dbserver/util/db'
require_relative '../common/util/config'

FILESPEC = '*.{M,m}{P,p}3'
# FILESPEC = "*.mp3"
# FILESPEC = "*.ogg"
# Scanner.rb

$db = Db.new

def tag_file_with_hash(mp3file, hash)
  puts "  >>> Getting tag info for file '#{mp3file}'"
  begin
    TagLib::FileRef.open(mp3file) do |mp3info|
      unless mp3info.null?
        tag = mp3info.tag
        songlen = mp3info.audio_properties.length_in_seconds
        songlen = songlen.nil? ? -1 : songlen.floor

        # save mp3info.tag.artist, mp3info.tag.title, mp3info.length
        safe_artist = tag.artist
        safe_artist = safe_artist[0..99] if safe_artist.length > 100
        tag = { artist: safe_artist, title: tag.title, secs: songlen }
        $db.write_tag(hash, mp3file, tag)
      end
    end
  rescue StandardError => e
    puts "Unable to read tag in file (#{e.message})! Skipping..."
  end
end

# Options
options = { dates: true }
OptionParser.new do |opts|
  opts.banner = 'Usage: Scanner.rb [options]'
  opts.on('-n', '--no-date', 'DO NOT stamp tag dates with the file dates') { options[:dates] = false }
  opts.on('-l', '--long', 'Long process, check ALL files in directory for tags') { options[:long] = true }
  opts.on('-rDIR', '--rootdir=DIR', 'Specify the root directory') { |v| options[:rootdir] = v }
end.parse!

# Recurse through directory and check database for any files that are missing tags
# Try to tag these files
#    - for any file that didn't have a tag, and still doesn't have one, record this somewhere(??)
rootdir = options[:rootdir] || MP3S::Config::MP3_ROOT
rootdir.sub!(%r{/$}, '') # no trailing slash pls
puts "Scanning through given base directory #{rootdir}"
files = Dir.glob("#{rootdir}/**/#{FILESPEC}")

puts "Filespec was '#{"#{rootdir}/**/#{FILESPEC}"}' files"
raise "No files found in given root dir #{rootdir}" if files.empty?

puts "Files found in directory: #{files.size}"
allfiles = 0
taggedfiles = 0
files.each do |f|
  safe_filename = f
  allfiles += 1
  begin
    safe_filename.encode!('utf-8')
  rescue StandardError
    puts "UTF-8 error with #{f}! Skipping :-( "
    next
  end
  # check the db for the tag
  # TODO: should probably only compute the hash in a 'long' version - check args
  file_hash = Digest::SHA1.hexdigest(safe_filename)
  tag = $db.find_song(file_hash)[0]
  # either 1. tag exists and has data, 2. tag exists but has nils or 3. tag is nil (no record found)
  if tag.nil?
    puts "Need to find the tag for file: #{safe_filename}"
    # compute and write the tag!
    tag_file_with_hash(safe_filename, file_hash)
    taggedfiles += 1
  else
    dbfilepath = tag[:song_filepath]
    if options[:dates]
      dte = File.mtime(safe_filename).strftime('%Y-%m-%d')
      $db.update_tag_date(file_hash, dte)
    end

    if dbfilepath != safe_filename
      puts "*** NOTE! Tag for #{safe_filename} is not the same as the one in the db!"
      puts "   db filepath   : #{dbfilepath}"
      puts "   found filepath: #{safe_filename}"
    end
  end
end

puts "Total  files: #{allfiles}"
puts "Tagged files: #{taggedfiles}"
