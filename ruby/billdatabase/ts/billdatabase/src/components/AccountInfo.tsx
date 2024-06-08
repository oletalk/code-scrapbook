import { AccountInfo } from '../common/types'

/* TODO: save account info is done separately so do it here */
interface AccountInfoProps {
  info: AccountInfo,
  onChange: Function
}

function EditAccountInfo (props: AccountInfoProps) {
  const info = props.info

  return (
    <div>
      <div className={info.closed ? 'sender_account_closed' : 'sender_account'}>
        <label htmlFor='account_number'>Account number: </label>
        <input 
          onChange={(e) => 
            props.onChange({...props.info, 'account_number': e.target.value} as AccountInfo)} 
          name="account_number" 
          className='fieldval' 
          value={info.account_number} />
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
    </div>
  )
}

export default EditAccountInfo;