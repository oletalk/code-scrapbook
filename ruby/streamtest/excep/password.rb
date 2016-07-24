class UserCreationError < StandardError
    def initialize(msg="Unknown error")
        super
    end
end

class PasswordError < UserCreationError
    def initialize(msg="Unknown error with password")
        super
    end
end
