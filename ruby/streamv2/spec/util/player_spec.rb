require_relative '../../util/player'



describe Player do
  context "given file and command" do
    it "plays the song" do
      cmd = 'echo XXXX'
      song = 'hello'
      player = Player.new
      actual = player.play_song(cmd, song)
      expect(actual.songdata).to eq("hello\n")
      expect(actual.command).to eq('echo hello')
      expect(actual.warnings).to eq('')
    end

  end

  context "given bad command" do
    it "outputs error message to be logged" do
      cmd = 'touch XXXX'
      song = '/foo'
      player = Player.new
      actual = player.play_song(cmd, song)
      expect(actual.songdata).to eq("")
      expect(actual.command).to eq('touch /foo')
      expect(actual.warnings).to eq("touch: /foo: Permission denied\n")
    end

  end

end
