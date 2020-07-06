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
end
