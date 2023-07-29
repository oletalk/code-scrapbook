# frozen_string_literal: true

require_relative '../../lib/stream/player'

describe 'Player' do
  it 'fails to play an unknown type file' do
    foo = double('logger')
    stub_const('Logging::Logger', foo)
    allow(foo).to receive(:new).and_return(foo)
    allow(foo).to receive(:error)
    p = Player.new

    expect {
      p.play_downsampled('blah')
    }.to raise_error(RuntimeError)
  end

  it 'plays an mp3' do
    foo = double('logger')
    allow(Open3).to receive('capture3').and_return('downsampledoutput')
    stub_const('Logging::Logger', foo)
    allow(foo).to receive(:new).and_return(foo)
    allow(foo).to receive(:info)

    p = Player.new

    actual = p.play_downsampled('testfiles/file.mp3')
    expect(actual).to eq('downsampledoutput')
  end

end
