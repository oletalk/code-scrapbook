interface Common {
  json_class: string
  id:string
}

export enum NavType {
  Home, Documents, NewDocument, EditDocument,
  Payments, Senders, NewSender, EditSender, SenderContacts,
  DocumentTypes,
  TagTypes
}
export interface DocumentType extends Common {
  name: string
}

export interface NamedType extends Common {
  name: string
}

export interface DocumentInfo extends Common {
  created_at: string,
  received_date: string,
  summary: string,
  due_date: string,
  paid_date: string,
  doc_type: DocumentType,
  sender: SenderInfo,
  file_location: string,
  comments: string,
  sender_account: AccountInfo

}
export interface AccountInfo extends Common {
  closed: boolean,
  sender_id: string,
  account_number: string,
  account_details: string,
  comments: string
}

export interface ContactInfo extends NamedType {
  sender_id: string,
  contact: string,
  comments: string
}
export interface TagObject extends Common {
  description: string,
  color: string,
  changed: boolean
}

export interface SenderInfo extends NamedType {
  created_at: Date,
  username: string,
  password_hint: string,
  comments: string,
  sender_accounts: AccountInfo[],
  sender_contacts: ContactInfo[],
  sender_tags: TagObject[]
}

export interface SelectFromListOfNamedTypes<T extends NamedType | AccountInfo> {
  itemList: T[] | undefined,
  selectName: string,
  selectedItem: string | undefined,
  changeCallback: (id : string) => void,
  noItemMessage: string | undefined
}

export function emptyDocument() : DocumentInfo {
  return {
    id: '',
    json_class: '',
    created_at: '',
    received_date: '',
    summary: '',
    due_date: '',
    paid_date: '',
    doc_type: {
      name: '',
      id: '',
      json_class: ''
    },
    sender: emptySender(),
    file_location: '',
    comments: '',
    sender_account: emptyAccount()
  
  }
}
export function emptySender() : SenderInfo {
  return {
    name: '',
    id: '',
    json_class: '',
    created_at: new Date(),
    username: '',
    password_hint: '',
    comments: '',
    sender_accounts: [],
    sender_contacts: [],
    sender_tags: []  
  }
}
export function emptyAccount() : AccountInfo {
  return {
    json_class: '',
    closed: false,
    id: '',
    sender_id: '',
    account_number: '',
    account_details: '',
    comments: ''
  }
}

  export function emptyContact() : ContactInfo {
    return {
    json_class: '',
    id: '',
    sender_id: '',
    name: '',
    contact: '',
    comments: ''
  }
}

export function adaptedFields(ac: AccountInfo) : Object {
  return {
      id: ac.id,
      account_closed: ac.closed ? 'Y' : 'N',
      sender_id: ac.sender_id,
      account_number: ac.account_number,
      account_details: ac.account_details,
      comments: ac.comments
  }
}

export class ListUtils<T extends Common> {

  public replaceItemById (list: T[], newItem: T) : T[] {
    let ret: T[] = []
    for (let x = 0; x < list.length; x++) {
      if (list[x].id === newItem.id) {
        ret.push(newItem)
      } else {
        ret.push(list[x])
      }
    }
    return ret
  }
  
}
