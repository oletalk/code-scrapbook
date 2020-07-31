require_relative '../util/config'
require_relative '../util/logging'

module Manip

  def self.shorten_titles(result_map, max_length)
    ret = []
    result_map.each do |row|
      returned_row = row
      title = returned_row['title']
      if !title.nil? && title.size > max_length
        returned_row['title'] = title[0..max_length-4] + '...'
      end
      ret.push(returned_row)
    end
    ret
  end

  def self.collapse(str)
    str.gsub(/\s+/, " ").strip
  end

  def self.date_from_db(str) # str is of the form '2020-07-03 11:27:15.296414'
    ret = nil
    begin
      dte = DateTime.parse(str)
      ret = dte.strftime(MP3S::Config::Misc::DATE_FORMAT)
    rescue ArgumentError => e 
      Log.log.error("Problem parsing given date: #{e}")
    end
    ret
  end
end
