export const BACKEND_URL = 'http://localhost:4567'

/*
  verb-(new?)-noun-URL
*/
//     fetch('http://localhost:4567/sender/' + id)

export const fetchSenderUrl = (sender_id: String) => {
  return BACKEND_URL + '/sender/' + sender_id
}

export const updateSenderTagUrl = (sender_id: String, tag_id: String) => {
  return BACKEND_URL + '/sendertag/' + sender_id + '/' + tag_id
}
/** URL to fetch or update a document */
export const fetchDocumentUrl = (document_id: String) => {
  return BACKEND_URL + '/document/' + document_id
}

export const fetchSenderAccountsUrl = (sender_id: String) => {
  return BACKEND_URL + '/json/sender/' + sender_id + '/accounts'
}

export const fetchSenderNotesUrl = (sender_id: String) => {
  return BACKEND_URL + '/json/sender/' + sender_id + '/notes'
}

export const saveNewSenderNoteUrl = (sender_id: String) => {
  return BACKEND_URL + '/sender/' + sender_id + '/note'
}



export const saveNewAccountUrl = (sender_id: String) => {
  return BACKEND_URL + '/sender/' + sender_id + '/account_new'
}

export const saveNewDocumentUrl = () => {
  return BACKEND_URL + '/document_new'
}

export const saveNewSenderUrl = () => {
  return BACKEND_URL + '/sender_new'
}

export const updateAccountUrl = (account_id: String) => {
  return BACKEND_URL + '/senderaccount/' + account_id
}

export const saveNewContactUrl = (sender_id: String) => {
  return BACKEND_URL + '/sender/' + sender_id + '/contact_new'
}

export const updateContactUrl = (contact_id: String) => {
  return BACKEND_URL + '/sendercontact/' + contact_id
}


