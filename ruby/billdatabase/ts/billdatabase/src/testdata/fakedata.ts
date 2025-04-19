import { AccountInfo } from "../common/types-class"

export function fakeAccount(acc_number: string, acc_id: string, sd_id: string) : AccountInfo {
    return {
      json_class: 'AccountInfo',
      id: acc_id,
      closed: false,
      sender_id: sd_id,
      account_number: acc_number,
      account_details: '',
      comments: 'test data'
    }
  
}