type Common = {
  json_class: string,
  id:string
}

export type TagObject = Common & {
  description: string,
  color: string,
  changed: boolean
}

export type AccountInfo = Common & {
  closed: boolean,
  sender_id: string,
  account_number: string,
  account_details: string,
  comments: string
}

export type ContactInfo = Common & {
  sender_id: string,
  name: string,
  contact: string,
  comments: string
}

export type SenderInfo = Common & {
  name: string,
  created_at: Date,
  username: string,
  password_hint: string,
  comments: string,
  sender_accounts: AccountInfo[],
  sender_contacts: ContactInfo[],
  sender_tags: TagObject[]
}

export const emptyAccount = () => {
  return {
    json_class: '',
    closed: false,
    id: '',
    sender_id: '',
    account_number: '',
    account_details: '',
    comments: ''
  } as AccountInfo
}

  export const emptyContact = () => {
    return {
    json_class: '',
    id: '',
    sender_id: '',
    name: '',
    contact: '',
    comments: ''
  } as ContactInfo 
}

type CommonListItem = AccountInfo | ContactInfo | TagObject

export const replaceItemById = (list: CommonListItem[], newItem: CommonListItem) : CommonListItem[] => {
  let ret: CommonListItem[] = []
  for (let x = 0; x < list.length; x++) {
    if (list[x].id === newItem.id) {
      ret.push(newItem)
    } else {
      ret.push(list[x])
    }
  }
  return ret
}

export const adaptedFields = (ac: AccountInfo) => {
  return {
      id: ac.id,
      account_closed: ac.closed ? 'Y' : 'N',
      sender_id: ac.sender_id,
      account_number: ac.account_number,
      account_details: ac.account_details,
      comments: ac.comments
  }
}

export const isBlank = (str: Object) => {
  if (typeof str == 'undefined') {
    return true
  } else if (typeof str == 'string') {
    if (str.trim() === '') {
      return true
    } else {
      return false
    }
  }
}