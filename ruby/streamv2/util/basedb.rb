require 'pg'

class BaseDb
  # GENERIC SQL FETCH - use only for *parametrised* statements.
  def collection_from_sql(sql: , params: , result_map: , description:)
    ret = []

    #result_map is like { "hash" => "file_hash", "title" => "display_title"}
    connect_for(description) do
      @conn.exec_params(sql, params) do | result |
        result.each do |result_row|
          new_row = {}
          result_map.each do |key,result_key|
            if result_key == true
              #puts "#{key} -> #{key} (#{result_row[key.to_s]})"
              new_row[key] = result_row[key.to_s]
            else
              #puts "#{key} -> #{result_key} (#{result_row[result_key]})"
              new_row[key] = result_row[result_key]
            end
          end
          ret.push(new_row)
        end
      end
    end
    #puts 'returning result'
    ret
  end

  def connect_for(description)
    begin
        @conn = new_connection
        @conn.transaction do
          yield # <-- do your @conn.exec and result processing and whatever here
        end
    rescue PG::Error => e
        error_description = description
        puts '*** SQL Syntax Error ***'
        if error_description == nil
          Log.log.error "Problem performing operation: #{e}"
        else
          Log.log.error "Problem #{error_description}: #{e}"
        end
        @conn.close if @conn
    end
  end

  def new_connection
    PG.connect(dbname: MP3S::Config::DB::NAME, user: MP3S::Config::DB::USER)
  end
end
