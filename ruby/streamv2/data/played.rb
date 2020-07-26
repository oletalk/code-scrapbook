class Played
  attr_reader :songdata, :command, :warnings

  def initialize(sd, c, w=nil)
    @songdata = sd
    @command = c
    @warnings = w
  end

end
