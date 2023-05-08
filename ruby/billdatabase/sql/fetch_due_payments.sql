select s.name,
  d.summary,
  d.due_date,
  d.paid_date,
  d.id as document_id,
  case
    when (
      due_date < now()
      and paid_date is null
    ) then 'overdue'
    when (
      due_date >= now()
      and paid_date is null
    ) then 'unpaid'
    else 'paid'
  end as status
from bills.document d
  join bills.sender s on d.sender_id = s.id
where due_date is not null
  and due_date > (now() - interval '1 year')
order by due_date