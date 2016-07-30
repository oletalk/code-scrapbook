require 'bcrypt'
    
class User
    attr_accessor :username, :cryptedpass
    def initialize(username, cryptedpass, encrypted=true)
        @username = username # TODO: store something else in here from the db
        if encrypted
            @cryptedpass = BCrypt::Password.new( cryptedpass ) # Password.create to save new passwords!!
        else
            @cryptedpass = cryptedpass #test mode??
        end
    end

    def password_matches(plainpass)
        @cryptedpass == plainpass
    end
end 
