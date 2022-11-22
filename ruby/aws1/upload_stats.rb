require 'aws-sdk-s3'
require 'pg'
require 'csv'

t = Time.now
append = t.strftime("%Y%m%d.%H%M%S")
puts 'Connecting to database.'
pw = File.read('conf/db_pw.txt').chomp
conn = PG.connect(host: '192.168.0.2', dbname: 'postgres', user: 'web', password: pw)
sql = 'select * from mp3s_stats'
puts 'Creating CSV with contents of MP3S_STATS'
filename = "mp3sstats.#{append}.csv"

csvbody = ''
conn.exec(sql) do |result|
  result.each do |row|
    csvbody << [row['category'], row['item'], row['plays'], row['last_played'] ].to_csv
  end
end

puts "Attempting to upload #{filename} to S3."
bucket_name = 'oletalk'
region = 'us-east-1'
s3_client = Aws::S3::Client.new(region: region)

def object_uploaded?(s3_client, bucket_name, object_key, filebody)
  response = s3_client.put_object(
    body: filebody,
    bucket: bucket_name,
    key: object_key
  )
  if response.etag
    return true
  else
    return false
  end
rescue StandardError => e
  puts "Error uploading object: #{e.message}"
  return false
end

if object_uploaded?(s3_client, bucket_name, filename, csvbody)
  puts 'success!'
else
  puts 'failed...'
end
puts "Done. Feel free to delete #{filename} if you wish."

