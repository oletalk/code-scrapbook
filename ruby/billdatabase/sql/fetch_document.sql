select d.id,
  received_date,
  doc_type_id,
  dt.name as doc_type_name,
  d.sender_id,
  summary,
  s.name as sender_name,
  due_date,
  paid_date,
  file_location,
  d.comments,
  sa.id as sender_account_id,
  sa.account_number
from bills.document d
  join bills.doc_type dt on d.doc_type_id = dt.id
  join bills.sender s on d.sender_id = s.id
  left join bills.sender_account sa on d.sender_account_id = sa.id
where d.id = $1