import { isBlank } from '../common/types'
import { ContactInfo } from '../common/types-class'
import * as Constants from '../common/constants'
import { doPost } from '../common/fetch'
/* TODO: save account info is done separately so do it here */
interface ContactInfoProps {
  info: ContactInfo,
  sender_id: string,
  onChange: (co : ContactInfo) => void,
  refreshCallback: Function
}

function EditContactInfo (props: ContactInfoProps) {
  const info = props.info

  const saveContact = () => {
    const url = isBlank(props.info.id) 
      ? Constants.saveNewContactUrl(props.sender_id)
      : Constants.updateContactUrl(props.info.id)
    const addingContact = isBlank(props.info.id)
    if (addingContact) {
      console.log('SAVING NEW CONTACT')
      console.log(info)
    } else {
      console.log('updating contact id ' + props.info.id)
      console.log(info)

    }
    // TODO
    doPost(url, props.info,
    addingContact, props.refreshCallback, 
    'refresh sender data from db')
  }

  return (
    <div>
      <div className='sender_contact'>
        <label htmlFor='contact_info'>Contact info (phone, etc): </label>
        <input 
        onChange={(e) => 
          props.onChange({...props.info, 'contact': e.target.value})
        }
          name="contact_info" 
          className='fieldval' 
          value={info.contact} />
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
      <input type="button" onClick={() => saveContact()} value={isBlank(props.info.id) ? 'Save new Contact' : 'Update Contact'} />

    </div>
  )
}

export default EditContactInfo;