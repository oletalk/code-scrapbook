# frozen_string_literal: true

require 'optparse'
require_relative '../stream/sftpget'

# utility to find newly updated files in the SFTP store
class CheckRecent
  include SftpGet

  def parsedoptions(args)
    options = {
      secs: 86_400 * 7 # a week
    }
    OptionParser.new do |opts|
      opts.banner = 'Usage: checkrecent.rb -d <remote directory>'

      opts.on('-dDIR', '--directory=DIR', 'remote directory') do |d|
        options[:dir] = d
      end
      opts.on('-sSECS', '--seconds=SECS', 'seconds in the past') do |s|
        options[:secs] = s
      end
    end.parse!(args)
    options
  end

  def main(args)
    options = parsedoptions(args)
    raise 'Remote directory not given' unless options.key?(:dir)

    sftpcheckdir(options[:dir], options[:secs]) do |remotefile|
      puts remotefile
    end
  end
end

foo = CheckRecent.new
foo.main(ARGV)
