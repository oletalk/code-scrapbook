require 'spec_helper'

describe '::play_song' do
    before (:each) do
        @player = Player.new
        @command = '/bin/echo -n XXXX'
    end

    it 'should substitute the filename for XXXXs' do
        x = @player.play_song(@command, 'foobar')
        expect(x[:songdata]).to eq 'foobar'
    end

    it 'should escape input to produce correct output' do
        str = "it's wonderful"
        x = @player.play_song(@command, str)
        expect(x[:command]).to eq %{/bin/echo -n it\\'s\\ wonderful}
    end

    it 'should produce correct output after escaping' do
        str = "it's marvellous!"
        x = @player.play_song(@command, str)
        expect(x[:songdata]).to eq str
    end
end

