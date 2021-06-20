# frozen_string_literal: true

# Class to hold data returned from player
class Played
  attr_reader :songdata, :command, :warnings

  def initialize(sdata, cmd, wrn=nil)
    @songdata = sdata
    @command = cmd
    @warnings = wrn
  end
end
