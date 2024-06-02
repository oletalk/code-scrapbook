import { ContactInfo } from '../common/types'

/* TODO: save account info is done separately so do it here */
interface ContactInfoProps {
  info: ContactInfo
}

function EditContactInfo (props: ContactInfoProps) {
  const info = props.info

  return (
    <div>
      <div className='sender_contact'>
        <label htmlFor='contact_info'>Contact info (phone, etc): </label><input name="account_number" className='fieldval' value={info.contact} />
      </div>
      <div className='fieldval'>
        <label htmlFor='comments'>Comments: </label><textarea name='comments' className='fieldval' >{info.comments}</textarea>
      </div>
    </div>
  )
}

export default EditContactInfo;