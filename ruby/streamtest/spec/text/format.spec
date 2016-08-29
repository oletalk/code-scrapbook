require 'spec_helper'

describe 'Format::html_list' do
    it 'should return an empty list given an empty list' do
        x = [ ]
        expect(Format.html_list(x)).to eq ''
    end

    it 'should create a link for one item properly' do
        x = [ { hash: 'abcdef12', title:'Awesome Song 1' } ]
        expect(Format.html_list(x)).to eq %{ <a href='/play/abcdef12'>Awesome Song 1</a> }
    end

    it 'should create links separated correctly' do
        x = [ { hash: 'abcdef12', title:'Awesome Song 1' },
              { hash: 'fdca12a2', title:'Great Tune' } ]
        expect(Format.html_list(x)).to eq %{ <a href='/play/abcdef12'>Awesome Song 1</a> <br/>
 <a href='/play/fdca12a2'>Great Tune</a> }
    end
end

describe '::json' do
    it 'should create a json string as expected' do
        x = { hash: 'abcdef12', title:'Awesome Song 1' }
        expect(Format.json(x)).to eq "{\"hash\":\"abcdef12\",\"title\":\"Awesome Song 1\"}"
    end
    it 'should create an empty json string as expected' do
        x = {}
        expect(Format.json(x)).to eq "{}"
    end
end

describe '::json_list' do
    it 'should create a json list string as expected' do
        x = [ { hash: 'abcdef12', title:'Awesome Song 1' }, { hash: '34dfabcj12', title: 'Great Tune 2' }, { hash: '53afdce1aab', title: 'Something' } ]
        expect(Format.json(x)).to eq "[{\"hash\":\"abcdef12\",\"title\":\"Awesome Song 1\"},{\"hash\":\"34dfabcj12\",\"title\":\"Great Tune 2\"},{\"hash\":\"53afdce1aab\",\"title\":\"Something\"}]"
    end
end

describe '::play_list' do
    it 'should create a play list with the expected format' do
        x = [ { hash: 'abcdef12', title:'Awesome Song 1', secs:-1 },
              { hash: 'fdca12a2', title:'Great Tune', secs:200 } ]
        expect(Format.play_list(x, 'localhost:2345')).to eq %{#EXTM3U
#EXTINF:-1,Awesome Song 1
http://localhost:2345/play/abcdef12
#EXTINF:200,Great Tune
http://localhost:2345/play/fdca12a2}
    end
end
