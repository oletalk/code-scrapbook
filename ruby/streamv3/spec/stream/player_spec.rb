# frozen_string_literal: true

require_relative '../../lib/stream/player'
require_relative '../support/logging_helpers'

RSpec.configure do |c|
  c.include LoggingHelpers
end

describe 'Player' do
  it 'fails to play an unknown type file' do
    fake_logging
    p = Player.new

    expect { p.play_downsampled('blah') }.to raise_error(RuntimeError)
  end

  it 'plays an mp3' do
    allow(Open3).to receive('capture3').and_return('downsampledoutput')
    fake_logging

    p = Player.new

    # TODO: separate out logic to make a better test....
    actual = p.play_downsampled('testfiles/file.mp3')
    expect(actual).to eq('downsampledoutput')
  end
end
