UPDATE bills.document
SET received_date = $1,
  due_date = $2,
  paid_date = $3,
  comments = $4,
  sender_account_id = $5
WHERE id = $6