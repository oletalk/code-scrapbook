added new 'closed' field to account:
DATABASE
* add closed field (not null default 'N') to bills.sender_account

WEBAPP
* go into senderhandler.rb and add 'closed' into ACCOUNT_FIELDS, and add update for closed field into 'upd_sender_account' method
* go into senderaccount.rb and add :closed as an accessor and a line for 'closed' in fill_out_from(result_row)
* go into app.rb and add row updating (SenderAccount) sa.closed based on 'account_closed' in the params

FRONT END
* go into single_sender.rb and insert new UI for behaviour when account.closed == 'Y'
* go into entity.js and change collectElementsOfFrom to handle checkbox input
