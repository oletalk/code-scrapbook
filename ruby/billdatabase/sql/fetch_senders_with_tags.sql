select 
    s.id, created_at, name, username, password_hint, comments, 
     t.id as tag_id, t.tag_name, t.color
  from bills.sender s, bills.sender_tag st, bills.tag_type t 
  where s.id = st.sender_id 
  and st.tag_id = t.id
  order by s.id, t.id;