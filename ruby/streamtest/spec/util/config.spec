require 'spec_helper'

describe 'MP3S::Config' do
    it 'should have a valid WEB_ROOT directory' do
        expect(File).to exist (MP3S::Config::WEB_ROOT)
    end

    it 'should have a valid MP3_ROOT directory' do
        expect(File).to exist (MP3S::Config::MP3_ROOT)
    end

    it 'should have a valid raw play (PLAY_RAW) command' do
        x = MP3S::Config::PLAY_RAW
        first_word = /[\w\/]+/.match(x)[0]
        expect(File).to exist (first_word)
    end

    it 'should have a valid MP3 downsample command' do
        x = MP3S::Config::PLAY_DOWNSAMPLED_MP3
        first_word = /[\w\/]+/.match(x)[0]
        expect(File).to exist (first_word)
    end

    it 'should have a valid OGG downsample command' do
        x = MP3S::Config::PLAY_DOWNSAMPLED_OGG
        first_word = /[\w\/]+/.match(x)[0]
        expect(File).to exist (first_word)
    end
end
