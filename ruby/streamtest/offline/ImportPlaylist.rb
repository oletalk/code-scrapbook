require 'optparse'
require_relative '../util/dbbase'
require_relative '../util/db_songlist'

ERROR_LIMIT = 25

#puts 'Inspecting all songs in the db...'
#song_list = db.list_songs("#{MP3S::Config::MP3_ROOT}/")
#puts "Number of songs: #{song_list.size}"

def displ(optval, optdescr)
    if $verbose
        if optval != nil
            puts "Requested #{optdescr} was #{optval}"
        end
    end
end

errors = {}

# Defaults
$verbose = false
$replace = false

# Options
options = {}
playlist = nil
playlistname = nil
    OptionParser.new do |opts|
    opts.banner = "Usage: ImportPlaylist.rb <path to playlist file> [options]"
    opts.on('-f', '--from f', 'First line (starting from 1) to process (default 1)') { |f| 
        options[:from] = f
    }
    opts.on('-t', '--to t', 'Last line (starting from 1) to process (default last line of file') { |t|
        options[:to] = t
    }
    opts.on('-p', '--playlist p', 'playlist file to read') { |p| playlist = p }
    opts.on('-r', '--replace', 'replace') { $replace = true }
    opts.on('-n', '--name n', 'name to give playlist (1 word)') { |p| playlistname = p }
    opts.on('-v', '--verbose', 'Verbose') { $verbose = true }
end.parse!

if playlist.nil?
    puts "Playlist file not provided (use -p)"
    Kernel.exit(1)
end

if playlistname.nil?
    puts "Please name your playlist (using -n)"
    Kernel.exit(1)
end

# Read all the songs/hashes in
hashes = {}
conn = DbBase.new.new_connection
conn.exec_params('SELECT song_filepath, file_hash FROM mp3s_tags') do |result|
    result.each do |row|
        song = row['song_filepath']
        song.strip
        hashes[song] = row['file_hash']
    end
    conn.finish
end
puts "STORED #{hashes.length} song hashes."

# Check each line in file, determine how many songs can be imported (straight match against file names in tag db)
# Try to tag these files
#    - for any file that didn't have a tag, and still doesn't have one, record this somewhere(??)
# select file_hash from mp3s_tags where song_filepath = '<filepath>';
displ(options[:from], "'from' value")
displ(options[:to], "'to' value")
line_num = 0
text=File.open(playlist).read # what if file doesn't exist?
text.gsub!(/\r\n?/, "\n")
# go through playlist, storing files found with their hashes
#so we can do the playlist easily later on
tags = []
found = 0
text.each_line { |line|
    line.gsub!(/\s+$/, "")
    if line.end_with?("\n")
        raise "still ends with a newline"
    end
    line_num += 1
    if hashes.key?(line)
        # TODO: add to custom playlist
        tags.push({'hash' => hashes[line]})
        if $verbose
            puts "Found song #{line}"
        end
        found += 1
    else
        errors[line] = "not found" 
    end
}

puts "Found #{found} out of #{line_num} song(s)."
#puts "Resulting tags: #{tags}"
puts "Saving songlist of #{tags.size} now."

SongListDb.new.save_songlist(playlistname, tags, 'colin', !$replace) # need an owner, hardcoded colin for now
