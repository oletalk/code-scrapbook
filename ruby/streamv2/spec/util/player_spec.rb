# frozen_string_literal: true

require_relative '../../dbserver/util/player'

describe Player do
  context 'given file with plus sign in it and command' do
    it 'plays the song' do
      cmd = 'echo XXXX'
      song = 'hello + there'
      player = Player.new
      actual = player.play_song(cmd, song)
      expect(actual.songdata).to eq("hello + there\n")
      expect(actual.command).to eq('echo "hello + there"')
      expect(actual.warnings).to eq('')
    end
  end

  context 'given filename with quotes in it and command' do
    it 'plays the song' do
      cmd = 'echo XXXX'
      song = "it's \"me\".mp3"
      player = Player.new
      actual = player.play_song(cmd, song)
      expect(actual.songdata).to eq("it's \"me\".mp3\n")
      expect(actual.command).to eq("echo \"it's \\\"me\\\".mp3\"")
      expect(actual.warnings).to eq('')
    end
  end

  context 'given bad command' do
    it 'outputs error message to be logged' do
      cmd = 'touch XXXX'
      song = '/foo'
      player = Player.new
      actual = player.play_song(cmd, song)
      expect(actual.songdata).to eq('')
      expect(actual.command).to eq('touch "/foo"')
      expect(actual.warnings).to eq("touch: /foo: Permission denied\n")
    end
  end
end
