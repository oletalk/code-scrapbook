# frozen_string_literal: true

require 'optparse'
require_relative '../stream/sftpget'

# utility to copy a list of files from the SFTP store
class CopyFromSftp
  include SftpGet

  def parsedoptions(args)
    options = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: copylistfromscp.rb -l <list of remote sftp files> -d ' \
                    '<local destination directory>'

      opts.on('-lLIST', '--list=LIST', 'File with list of SFTP urls') do |l|
        options['list'] = l
      end

      opts.on('-dDESTDIR', '--destination=DESTDIR', 'Local destination dir') do |d|
        options['destination'] = d
      end
    end.parse!(args)
    options
  end

  def main(args)
    options = parsedoptions(args)
    raise 'List of SFTP URLs not given' unless options.key?('list')
    raise 'Destination directory not given' unless options.key?('destination')

    files = File.readlines(options['list'], chomp: true)

    destdir = options['destination']
    puts files
    sftpbulkget(files, destdir)
  end
end

foo = CopyFromSftp.new
foo.main(ARGV)
