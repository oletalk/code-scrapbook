import { useState, useEffect, useCallback } from 'react'
import { useParams } from 'react-router-dom'
import { SenderInfo, TagObject, AccountInfo, ContactInfo } from '../common/types'
import EditAccountInfo from '../components/AccountInfo'
import EditContactInfo from '../components/ContactInfo'
import EditTagList from '../components/TagInfo'

interface EditSenderState {
  changed: boolean,
  saveTs: number,
  showNewAccount: boolean,
  showNewContact: boolean,
  tagMenu: TagObject[]
}

// 27/05/24 i had to rewrite this as a function-based component in order to 
//          access the path variable /sender/:id :-S
function EditSender() {
  const { id } = useParams()
  // console.log('starting up') <- this seems to fire EVERY TIME i make a change
  const [ sender, setSender ] = useState<SenderInfo>({
      json_class: '', id: '', name: '', created_at: new Date(), 
      username: '', password_hint: '', comments: '', 
      sender_accounts: [], sender_contacts: [], sender_tags: []
  })
  const [ state, setState ] = useState<EditSenderState>(
    {
      changed: false,
      saveTs: new Date().getTime(),
      showNewAccount: false,
      showNewContact: false,
      tagMenu: []
    }
  )
  const [ newAccount, setNewAccount ] = useState<AccountInfo>({
    json_class: '',
    closed: false,
    id: '',
    sender_id: '',
    account_number: '',
    account_details: '',
    comments: ''
    })
    const [ newContact, setNewContact ] = useState<ContactInfo>({
      json_class: '',
      id: '',
      sender_id: '',
      name: '',
      contact: '',
      comments: ''
      })
  const setChanged = () => {
    // do update, POST etc
    console.log('Updating sender id ' + id)
    setState(prevState => 
      {
        return {
      ...prevState,
      saveTs: new Date().getTime()
    }})
  }

  const getTagList = useCallback(() => {
    console.log('fetching full tag list...')
    fetch('http://localhost:4567/tags')
    .then((response) => {
    // Check if the request was successful
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
        return response.json()
      })
      .then((json) => {
        setState({
          ...state,
          tagMenu: json as TagObject[]
        })        })
  }, [id, state])
  
  // confusing advice on using useEffect... or not?
  // https://react.dev/learn/you-might-not-need-an-effect

  useEffect(() => {
    getTagList()

    console.log('fetching sender data.')
    fetch('http://localhost:4567/sender/' + id)
    .then((response) => {
    // Check if the request was successful
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
        return response.json()
      })
      .then((json) => {
        setSender(json)
      })
    }, [id, getTagList])

// i get a react hook warning about missing deps here, which i can quiet by including the sender state variable
// but then that makes the whole load run in an infinite loop
// i wasted half a day on trying to find best practices on SO, react.dev (half of the docs are out of date)
// before finally giving up ... 
// if i need the screen to re-render i'll refresh the thing

  if (sender === undefined) {
    return (
      <div>Sender info not yet loaded.</div>
    )
  } else {
    return (
      <div>
        <table className='senderdetail'>
          <tr>
            <td colSpan={4} >
              <span className='sendername'>{ sender.name}</span>
            </td>
          </tr>
          <tr>
            <td>
              <EditTagList 
                  sender_id={sender.id} 
                  info={sender.sender_tags}
                  taglist={state.tagMenu} />
            </td>
          </tr>
          <tr>
            <td>
              <label>Username</label>
              <span className='optional'> (optional)</span>: 
            </td>
            <td colSpan={2}>
              <input name="username" className='sender_field' 
                onChange={(e) => setSender({...sender, username: e.target.value } as SenderInfo)}
                value={sender.username} />
            </td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td>
              <label>Password hint</label>
              <span className='optional'> (optional): </span>
            </td>
            <td colSpan={2}>
              <input name="password_hint" className='sender_field' 
                onChange={(e) => setSender({...sender, password_hint: e.target.value } as SenderInfo)}
                value={sender.password_hint} />
            </td>
            <td>&nbsp;</td>
          </tr>
          {/* ---- ACCOUNTS WE HAVE WITH THE SENDER ---- */}
          {sender.sender_accounts.length === 0 
          ? <tr>
            <td>
              <div className='sender_account'>No Accounts yet setup for this sender</div>
            </td>
          </tr> 
          : sender.sender_accounts.map(ac => 
            <tr>
              <td colSpan={3} >
              <EditAccountInfo info={ac} />
              </td>
            </tr>
          )}
          {(state.showNewAccount) ? (
            <tr>
            <td colSpan={3} >
            <EditAccountInfo info={newAccount} />
            <input 
            type='button' 
            onClick={() => setState({
              ...state, showNewAccount: !state.showNewAccount
            })} value='Hide' />

              </td>
            </tr>
          ): (<tr><td>
            <input 
            type='button' 
            onClick={() => setState({
              ...state, showNewAccount: !state.showNewAccount
            })} value='Add new account' />
          </td></tr>)}
          {/* ---- CONTACT DETAILS WE HAVE WITH THE SENDER ---- */}
          {sender.sender_contacts.length === 0 
          ? <tr>
            <td>
              <div className='sender_contact'>No Contacts yet setup for this sender</div>
            </td>
          </tr>
          : sender.sender_contacts.map(co =>
            <tr>
            <td colSpan={3} >
            <EditContactInfo info={co} />
            </td>
          </tr>
        )}
                  {(state.showNewContact) ? (
            <tr>
            <td colSpan={3} >
            <EditContactInfo info={newContact} />
            <input 
            type='button' 
            onClick={() => setState({
              ...state, showNewContact: !state.showNewContact
            })} value='Hide' />

              </td>
            </tr>
          ): (<tr><td>
            <input 
            type='button' 
            onClick={() => setState({
              ...state, showNewContact: !state.showNewContact
            })} value='Add new contact' />
          </td></tr>)}
        </table>
        <input type="button" onClick={() => setChanged()} value="Update" />
    </div>
  )
  }

}

export default EditSender;