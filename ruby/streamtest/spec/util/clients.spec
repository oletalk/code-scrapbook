require './util/clients'

describe 'MP3S::Clients::List' do
    it 'should have a non-empty ip list' do
        x = MP3S::Clients::List
        expect(x.size).to be > 0
    end
    it 'should have a default allow action defined' do
        x = MP3S::Clients::Default
        expect(x).to have_key(:allow)
    end
end
