## any options? Progress bar?

require_relative '../util/db'

ERROR_LIMIT = 25

db = Db.new
puts 'Inspecting all songs in the db...'
song_list = db.list_songs("#{MP3S::Config::MP3_ROOT}/")
puts "Number of songs: #{song_list.size}"

errors = {}
song_list.each do |song|
	req_hash = song[:hash]
	title = song[:title]
	filepath = db.find_song(req_hash)
	unless File.file?(filepath)
		errors[req_hash] = filepath
	end
end

if errors.size > ERROR_LIMIT
	puts "The files for #{errors.size} tag(s) could not be found."
	puts "The number of errors exceeded #{ERROR_LIMIT}. You may want to run Scanner.rb to fix the tags."
	Kernel.exit(1)
end

if errors.size > 0
	puts "The files for #{errors.size} tag(s) could not be found:"
	errors.each do |key,value|
		puts "#{value} (#{key})"
	end
end
