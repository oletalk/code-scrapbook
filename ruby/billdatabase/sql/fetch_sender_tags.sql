select distinct s.id as sender_id,
  t.id as tag_id,
  s.is_active,
  t.tag_name,
  t.color
from bills.sender s
  left join bills.sender_tag st on s.id = st.sender_id
  join bills.tag_type t on st.tag_id = t.id
order by s.id;