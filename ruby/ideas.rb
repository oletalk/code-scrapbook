require 'wordlist'

print "Enter your new idea: "
idea = gets

# The original example doesn't work unless I make code_words a (gasp) global varible
# in both places unfortunately (i.e. code_words -> $code_words )
$code_words.each do |real, code|
	idea.gsub!( real, code )
end

print "File encoded. Please enter a name for this idea: "
idea_name = gets.strip
File::open( "idea-" + idea_name + ".txt", "w" ) do |f|
	f << idea
end
