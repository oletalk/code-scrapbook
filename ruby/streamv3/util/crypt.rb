# frozen_string_literal: true

require_relative '../data/user'
require 'bcrypt'

# A class for checking user credentials as part of authentication
class PwCrypt
  def initialize(pwfile)
    # keep in @list
    @userlist = {}
    lines = File.read(pwfile).split("\n")

    # contains username,hashed pw,and comma separated list of permissions
    lines.each do |line|
      entry = line.split(',')
      key = entry[0]
      passhash = entry[1]
      # everything else is permissions
      permissions = entry.slice(1..)
      @userlist[key] = StreamGuiUser.new(key, passhash, permissions)
    end
  end

  def test_password(user, pswd)
    !@userlist[user].nil? && BCrypt::Password.new(@userlist[user].hash) == pswd
  end

  def user_info(username)
    @userlist[username]
  end
end
