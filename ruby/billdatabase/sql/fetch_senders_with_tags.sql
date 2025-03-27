select 
    s.id, created_at, name, username, password_hint, comments, 
     t.id as tag_id, t.tag_name, t.color
  from bills.sender s
  left outer join bills.sender_tag st on s.id = st.sender_id
  left outer join bills.tag_type t on st.tag_id = t.id  
  order by s.id, t.id;