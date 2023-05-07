# frozen_string_literal: true

require_relative 'data/collectors/senderobjectcollector'
require_relative 'data/sendercontact'
require_relative 'data/sender'
require_relative 'data/mappers/genericmapper'
require_relative 'db/db'
require 'json'

Object.include(Db)

sql = %(
  select s.id as sender_id,
  s.name as sender_name,
  sc.name,
  sc.contact,
  sc.comments
from bills.sender s
  join bills.sender_contact sc on s.id = sc.sender_id
order by sender_name,
  name
)
soc = SenderObjectCollector.new('sender_id')

# create a sender
sender_object = proc { |result_row|
  ret = Sender.new(result_row['sender_id'], nil)
  ret.name = result_row['sender_name']
  ret
}

# create the sender component with the rest of the row
sender_contact_object = proc { |result_row|
  GenericMapper.new.create_from_row(result_row, SenderContact)
}

# attach the objects to each sender
sender_link_object = proc { |sender, objs|
  sender.add_contacts(objs)
}

senders = []
connect_for('reading sender contacts') do |conn|
  conn.exec(sql) do |result|
    senders = soc.process_result(result, sender_object, sender_contact_object, sender_link_object)
  end
end

senders.each do |sender|
  puts "*** SENDER id #{sender.id}"
  puts sender.to_json
end
