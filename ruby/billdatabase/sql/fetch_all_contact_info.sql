select s.id as sender_id,
  s.name as sender_name,
  sc.name,
  sc.contact,
  sc.comments
from bills.sender s
  join bills.sender_contact sc on s.id = sc.sender_id
order by sender_name,
  name