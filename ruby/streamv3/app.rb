# frozen_string_literal: true

require_relative 'db/listgen'

lg = ListGen.new
lg.fetch_playlist('amy')
