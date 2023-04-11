INSERT into bills.document (
    received_date,
    doc_type_id,
    sender_id,
    due_date,
    paid_date,
    file_location,
    comments,
    sender_account_id
  )
values ($1, $2, $3, $4, $5, $6, $7, $8)
returning id