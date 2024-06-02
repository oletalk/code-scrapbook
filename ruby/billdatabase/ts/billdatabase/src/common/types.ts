export type TagObject = {
  json_class: string,
  id: string,
  description: string,
  color: string,
  changed: boolean
}

export type AccountInfo = {
  json_class: string,
  closed: boolean,
  id: string,
  sender_id: string,
  account_number: string,
  account_details: string,
  comments: string
}

export type ContactInfo = {
  json_class: string,
  id: string,
  sender_id: string,
  name: string,
  contact: string,
  comments: string
}

export type SenderInfo = {
  json_class: string,
  id: string,
  name: string,
  created_at: Date,
  username: string,
  password_hint: string,
  comments: string,
  sender_accounts: AccountInfo[],
  sender_contacts: ContactInfo[],
  sender_tags: TagObject[]
}