import { isBlank } from '../common/types'
import { AccountInfo, adaptedFields } from '../common/types-class'
import { doPost } from '../common/fetch'
import * as Constants from '../common/constants'

interface AccountInfoProps {
  sender_id: string,
  info: AccountInfo,
  onChange: (ac : AccountInfo) => void,
  refreshCallback: Function
}

function EditAccountInfo (props: AccountInfoProps) {
  const info = props.info

  const toggleChecked = () => {
    // TODO move back inline
    props.onChange({...props.info, 'closed': !props.info.closed}) 
  }

  const saveAccount = () => {
    const url = isBlank(props.info.id) 
      ? Constants.saveNewAccountUrl(props.sender_id)
      : Constants.updateAccountUrl(props.info.id)
    const addingAccount = isBlank(props.info.id)
    if (addingAccount) {
      console.log('SAVING NEW ACCOUNT')
      console.log(info)
    } else {
      console.log('updating account id ' + props.info.id)
    }
    
    doPost(url, adaptedFields(props.info),
            addingAccount, props.refreshCallback, 
            'refresh sender data from db')
  }

  return (
    <div className={info.closed ? 'account_info_container_closed' : 'account_info_container'}>
      <div className={info.closed ? 'sender_account_closed' : 'sender_account'}>
        <label htmlFor='account_number'>Account number: </label>
        <input 
          onChange={(e) => 
            props.onChange({...props.info, 'account_number': e.target.value})} 
          name="account_number" 
          className='fieldval' 
          value={info.account_number} />
          <span className='account_closed'>Closed? 
            <input onClick={toggleChecked} type='checkbox' checked={props.info.closed} />
          </span>
      </div>
      <div className='fieldval'>
        <label htmlFor='account_details'>Account details: </label>
        <input 
          onChange={(e) => 
            props.onChange({...props.info, 'account_details': e.target.value})} 
          name="account_details" 
          className='fieldval' 
          value={info.account_details} />
      </div>
      <div className='fieldval'>
        <label htmlFor='comments'>Comments: </label>
        <textarea 
            onChange={(e) => 
              props.onChange({...props.info, 'comments': e.target.value})
            }
            name='comments' 
            className='fieldval' >{info.comments}</textarea>
      </div>
      <input type="button" onClick={() => saveAccount()} value={isBlank(props.info.id) ? 'Save new Account' : 'Update Account'} />
    </div>
  )
}

export default EditAccountInfo;