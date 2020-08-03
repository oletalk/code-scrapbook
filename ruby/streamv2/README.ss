You can install the StreamServer piece separately on another machine (which doesn't need libpq installed).

Make sure you have the same .hmac file in the root checkout directory on each machine.
Run (on the StreamServer machine):
bundle install --gemfile Gemfile.streamserver.only
rake ss ss_unit
