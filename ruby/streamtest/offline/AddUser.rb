require 'optparse'
require 'bcrypt'
require 'io/console'

require_relative '../excep/password.rb'
require_relative '../util/db_user.rb'
require_relative '../util/config.rb'

# Adduser.rb

# Options
options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: Adduser.rb <username>. \nYou will then be asked for the password."

    opts.on('-v', '--verbose', 'Be verbose (currently a noop)') { options[:verbose] = true }
end.parse!

db = UserDb.new
user = ARGV[0]
if  user != nil && user != '' && /^[a-zA-Z]\w+$/ =~ (user)
    puts "OK, you want to create a new user #{user}."
    begin
        puts "Please enter the password: "
        newpass = STDIN.noecho(&:gets)
        newpass.chomp!
        puts "Please re-enter that password: "
        chkpass = STDIN.noecho(&:gets)
        chkpass.chomp!
        raise PasswordError.new('Passwords do not match') unless newpass == chkpass
        cryptedpass = BCrypt::Password.create newpass
        db.add_user(user, cryptedpass)
    rescue UserCreationError => pe
        puts "Couldn't proceed - #{pe.message}"
        retry
    end
    # /[[:cntrl]]/ matches control characters
else
    puts "Invalid username."
end

