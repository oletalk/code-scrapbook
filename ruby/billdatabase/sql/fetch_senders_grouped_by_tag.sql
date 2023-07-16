select st.sender_id,
  t.tag_name,
  t.color
from bills.sender_tag st
  join bills.tag_type t on st.tag_id = t.id
order by t.tag_name,
  st.sender_id