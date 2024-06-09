import { AccountInfo, isBlank, adaptedFields } from '../common/types'
import * as Constants from '../common/constants'

/* TODO: save account info is done separately so do it here */
interface AccountInfoProps {
  sender_id: string,
  info: AccountInfo,
  onChange: Function,
  refreshCallback: Function
}

function EditAccountInfo (props: AccountInfoProps) {
  const info = props.info

  const toggleChecked = () => {
    // TODO move back inline
    props.onChange({...props.info, 'closed': !props.info.closed} as AccountInfo) 
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
    fetch(url,
      {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        method: "POST",
        body: JSON.stringify(adaptedFields(props.info))
      })
      .then((response) => {
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
      })
      .then((json) => {
        console.log(json)
        if (addingAccount) {
          console.log('need to refresh sender data from db')
          props.refreshCallback()
        }
      })
  }

  return (
    <div className={info.closed ? 'account_info_container_closed' : 'account_info_container'}>
      <div className={info.closed ? 'sender_account_closed' : 'sender_account'}>
        <label htmlFor='account_number'>Account number: </label>
        <input 
          onChange={(e) => 
            props.onChange({...props.info, 'account_number': e.target.value} as AccountInfo)} 
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
            props.onChange({...props.info, 'account_details': e.target.value} as AccountInfo)} 
          name="account_details" 
          className='fieldval' 
          value={info.account_details} />
      </div>
      <div className='fieldval'>
        <label htmlFor='comments'>Comments: </label>
        <textarea 
            onChange={(e) => 
              props.onChange({...props.info, 'comments': e.target.value} as AccountInfo)
            }
            name='comments' 
            className='fieldval' >{info.comments}</textarea>
      </div>
      <input type="button" onClick={() => saveAccount()} value={isBlank(props.info.id) ? 'Save new' : 'Update'} />
    </div>
  )
}

export default EditAccountInfo;