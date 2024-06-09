export const BACKEND_URL = 'http://localhost:4567'

/*
  verb-(new?)-noun-URL
*/
//     fetch('http://localhost:4567/sender/' + id)

export const fetchSenderUrl = (sender_id: String) => {
  return BACKEND_URL + '/sender/' + sender_id
}

export const saveNewAccountUrl = (sender_id: String) => {
  return BACKEND_URL + '/sender/' + sender_id + '/account_new'
}

export const updateAccountUrl = (account_id: String) => {
  return BACKEND_URL + '/senderaccount/' + account_id
}

