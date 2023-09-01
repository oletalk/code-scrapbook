# frozen_string_literal: true

require 'optparse'
require_relative '../stream/sftpget'
require_relative '../util/tagget'
require_relative '../db/hashsong'
require 'digest/sha1'

# utility to find newly updated files in the SFTP store
class CheckRecent
  include SftpGet

  def parsedoptions(args)
    options = {
      secs: 86_400 * 7, # a week
      replace: false
    }
    OptionParser.new do |opts|
      opts.banner = 'Usage: checkrecent.rb -d <remote directory>'

      opts.on('-dDIR', '--directory=DIR', 'remote directory') do |d|
        options[:dir] = d
      end
      opts.on('-sSECS', '--seconds=SECS', 'seconds in the past') do |s|
        options[:secs] = s
      end
      opts.on('-r', '--replace-existing', 'replace existing metadata if found') do
        options[:replace] = true
      end
    end.parse!(args)
    options
  end

  def get_hash(filename)
    safe_filename = filename
    begin
      safe_filename.encode!('utf-8')
    rescue StandardError
      puts "UTF-8 error with #{filename}!"
    end
    Digest::SHA1.hexdigest(safe_filename)
  end

  def main(args)
    tagget = TagGet.new
    options = parsedoptions(args)
    raise 'Remote directory not given' unless options.key?(:dir)

    if options[:replace]
      puts '** REPLACING any existing song metadata found'
    else
      puts '** not replacing any existing song metadata found'
    end

    sftpcheckdir(options[:dir], options[:secs]) do |remotefile|
      localfile = "/tmp/#{File.basename(remotefile)}"
      sftpget(remotefile, localfile)
      tag = tagget.read(localfile)
      system "rm #{Shellwords.escape(localfile)}"

      # TODO: write the tag to the database - see streamv2
      # create an empty hashsong
      puts "path: #{remotefile}, hash: #{get_hash(remotefile)}, tag: #{tag}"
      h = HashSong.new
      h.update_tag(
        path: remotefile,
        hash: get_hash(remotefile),
        tag: tag,
        replace: options[:replace]
      )
      puts tag
    end
  end
end

foo = CheckRecent.new
foo.main(ARGV)
