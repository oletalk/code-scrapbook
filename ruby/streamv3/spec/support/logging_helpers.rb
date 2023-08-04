# frozen_string_literal: true

require_relative '../../lib/db/db'

module LoggingHelpers
  def fake_logging
    foo = double('logger')
    stub_const('Logging::Logger', foo)
    allow(foo).to receive(:new).and_return(foo)
    allow(foo).to receive(:error)
    allow(foo).to receive(:info)
    allow(foo).to receive(:formatter=)
  end
end
