# frozen_string_literal: true

require_relative '../util/config'
require_relative '../util/logging'
require 'date'

module Manip
  def self.shorten_titles(result_map, max_length)
    ret = []
    result_map.each do |row|
      returned_row = row
      title = returned_row['title']
      returned_row['title'] = "#{title[0..max_length - 4]}..." if !title.nil? && title.size > max_length
      ret.push(returned_row)
    end
    ret
  end

  def self.collapse(str)
    str.gsub(/\s+/, ' ').strip
  end

  # str is of the form '2020-07-03'
  def self.date_from_db(str)
    date_from(str, MP3S::Config::Misc::DATE_FORMAT)
  end

  # str is of the form '2020-07-03 11:27:15.296414'
  def self.timestamp_from_db(str)
    date_from(str, MP3S::Config::Misc::TIMESTAMP_FORMAT)
  end

  def self.date_from(str, format_str)
    ret = nil
    begin
      dte = DateTime.parse(str)
      ret = dte.strftime(format_str)
    rescue ArgumentError => e
      Log.log.error("Problem parsing given date: #{e}")
    end
    ret
  end
end
