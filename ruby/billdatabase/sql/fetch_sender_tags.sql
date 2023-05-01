select s.id,
  t.tag_name
from bills.sender s
  left join bills.sender_tag st on s.id = st.sender_id
  join bills.tag_type t on st.tag_id = t.id
order by s.id