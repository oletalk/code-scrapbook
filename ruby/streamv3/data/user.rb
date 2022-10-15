# frozen_string_literal: true

# holds information about a user of the management gui
class StreamGuiUser
  attr_reader :user_name,
              :hash,
              :allowed_into_gui,
              :can_edit_playlists,
              :needs_to_downsample

  def initialize(uname, hsh, perms)
    @user_name = uname
    @hash = hsh
    @allowed_into_gui = false
    @can_edit_playlists = false
    @needs_to_downsample = true

    raise 'non-array class given to constructor!' if perms.class != Array

    perms.each do |p|
      case p
      when 'allow'
        @allowed_into_gui = true
      when 'no_downsample'
        @needs_to_downsample = false
      when 'playlist'
        @can_edit_playlists = true
      end
    end
  end
end
