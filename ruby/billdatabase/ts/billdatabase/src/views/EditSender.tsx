import { useState, useEffect, useCallback } from 'react'
import { NavType } from '../common/types-class'
import { useParams } from 'react-router-dom'
import Nav from '../components/Nav'

// import { SenderInfo, TagObject, AccountInfo, ContactInfo, replaceItemById, 
//   emptyAccount, emptyContact
//} from '../common/types'
import { SenderInfo, TagObject, AccountInfo, ContactInfo, ListUtils,
  emptyAccount, emptyContact
  } from '../common/types-class'
import { BACKEND_URL, fetchSenderUrl } from '../common/constants'
import EditAccountInfo from '../components/AccountInfo'
import EditContactInfo from '../components/ContactInfo'
import EditTagList from '../components/TagInfo'

enum SenderTab {
  General = 1,
  Accounts = 2,
  Contacts = 3
}
interface EditSenderState {
  changed: boolean,
  saveTs: number,
  currentTab: SenderTab,
  showNewAccount: boolean,
  showNewContact: boolean
}

// 27/05/24 i had to rewrite this as a function-based component in order to 
//          access the path variable /sender/:id :-S
function EditSender() {
  const { id } = useParams()
  // console.log('starting up') <- this seems to fire EVERY TIME i make a change
  const [ tagMenu, setTagMenu ] = useState<TagObject[]>([])

  const [ sender, setSender ] = useState<SenderInfo>({
      json_class: '', id: '', name: '', created_at: new Date(), 
      username: '', password_hint: '', comments: '', 
      sender_accounts: [], sender_contacts: [], sender_tags: []
  })
  const [ state, setState ] = useState<EditSenderState>(
    {
      changed: false,
      saveTs: new Date().getTime(),
      currentTab: SenderTab.General,
      showNewAccount: false,
      showNewContact: false
    }
  )

  const [ newAccount, setNewAccount ] = useState<AccountInfo>(
    emptyAccount()
  )
    const [ newContact, setNewContact ] = useState<ContactInfo>(
      emptyContact()
    )

  const tabSelected = (tabNum: SenderTab) => {
    return tabNum === state.currentTab
  }

  const switchTab = (newTab: SenderTab) => {
    setState({
      ...state,
      currentTab: newTab
    })
  }
  const doUpdate = () => {
    // do update, POST etc
    console.log('Updating sender id ' + id)
    console.log(sender)
    // TODO save top-level sender info POST /sender/:id

    // TODO add update button to AccountInfo and ContactInfo tsx's
    //      should be good to save it off of the props!

    setNewAccount(emptyAccount)
    setNewContact(emptyContact)
    setState({...state,
      saveTs: new Date().getTime(),
      showNewAccount: false,
      showNewContact: false
    })
  }

  const handleAccountChange = (ac: AccountInfo) => {
    const lu = new ListUtils<AccountInfo>()
    console.log('changing account info for account name ' + ac.id + ', details ' + ac.account_details)
    let newsender: SenderInfo = {
      ...sender,
      sender_accounts: lu.replaceItemById(sender.sender_accounts, ac)
    }
    setSender(newsender)
    setState({...state, changed: true})
  }

  const handleContactChange = (co: ContactInfo) => {
    const lu = new ListUtils<ContactInfo>()
    console.log('changing contact info for contact name ' + co.id + ', details ' + co.contact)
    let newsender: SenderInfo = {
      ...sender,
      sender_contacts: lu.replaceItemById(sender.sender_contacts, co)
    }
    setSender(newsender)
    setState({...state, changed: true})
  }

  const handleSenderChange = (kv: Object) => {
    setSender({
      ...sender,
      ...kv
    } as SenderInfo)
    setState({
      ...state,
      changed: true
    })
  }

  const getTagList = useCallback(() => {
    console.log('fetching full tag list...')
    fetch(BACKEND_URL + '/tags')
    .then((response) => {
    // Check if the request was successful
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
        return response.json()
      })
      .then((json) => {
        setTagMenu(json as TagObject[])
      })
  }, [state])
  
  // confusing advice on using useEffect... or not?
  // https://react.dev/learn/you-might-not-need-an-effect

  useEffect(() => {
    getTagList()

    if (typeof id === 'undefined') {
      return
    }
    console.log('fetching sender data.')

    fetch(fetchSenderUrl(id))
    .then((response) => {
    // Check if the request was successful
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
        return response.json()
      })
      .then((json) => {
        // fix the boolean fields
        let x = json as SenderInfo
        /* for (let y of x.sender_accounts) {
          console.log('account id ' + y.id 
          + ' closed? ' + y.closed
          + ' open? ' + !y.closed
        )
        }  */  
        setSender(x)
        setState({...state, changed: false})
      })
    }, [state.saveTs, id])

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
        <Nav page={NavType.EditSender} />
        <table className='tabs'>
        <tr>
            <td colSpan={4} >
              <span className='sendername'>{ sender.name}</span>
            </td>
          </tr>
        <tr>
            <td colSpan={4} className='tabContainer' >
            <button className={tabSelected(SenderTab.General) ? 'senderTabSelected' : 'senderTab' } 
                onClick={() => switchTab(SenderTab.General)}>General</button>&nbsp;
            <button className={tabSelected(SenderTab.Accounts) ? 'senderTabSelected' : 'senderTab' } 
                onClick={() => switchTab(SenderTab.Accounts)}>Accounts</button>&nbsp;
            <button className={tabSelected(SenderTab.Contacts) ? 'senderTabSelected' : 'senderTab' }  
                onClick={() => switchTab(SenderTab.Contacts)}>Contacts</button>
            </td>
          </tr>
        </table>
        <table className={tabSelected(SenderTab.General) ? 'senderdetail': 'senderdetail_hidden'}>
          <tr>
            <td>
              <EditTagList 
                  sender_id={sender.id} 
                  info={sender.sender_tags}
                  taglist={tagMenu} />
            </td>
          </tr>
          <tr>
            <td>
              <label>Username</label>
              <span className='optional'> (optional)</span>: 
            </td>
            <td colSpan={2}>
              <input name="username" className='sender_field' 
                onChange={(e) => handleSenderChange({username: e.target.value})}
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
                onChange={(e) => handleSenderChange({password_hint: e.target.value})}
                value={sender.password_hint} />
            </td>
            <td>&nbsp;</td>
          </tr>
        </table>
        <table className={tabSelected(SenderTab.Accounts) ? 'senderdetail': 'senderdetail_hidden'}>
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
              <EditAccountInfo 
                  info={ac} sender_id={sender.id}
                  refreshCallback={doUpdate}
                  onChange={(ac: AccountInfo) => handleAccountChange(ac)} />
              </td>
            </tr>
          )}
          {(state.showNewAccount) ? (
            <tr>
            <td colSpan={3} >
            <EditAccountInfo sender_id={sender.id}
                  info={newAccount} 
                  refreshCallback={doUpdate}
                  onChange={(ac: AccountInfo) => setNewAccount(ac)} />

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
        </table>
        <table className={tabSelected(SenderTab.Contacts) ? 'senderdetail': 'senderdetail_hidden'}>
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
            <EditContactInfo 
              info={co} sender_id={sender.id}
              refreshCallback={doUpdate}
              onChange={(co: ContactInfo) => handleContactChange(co)} />
            </td>
          </tr>
        )}
                  {(state.showNewContact) ? (
            <tr>
            <td colSpan={3} >
            <EditContactInfo 
                  info={newContact} sender_id={sender.id}
                  refreshCallback={doUpdate}
                  onChange={(co: ContactInfo) => setNewContact(co)} />
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
        <input type="button" disabled={!state.changed} onClick={() => doUpdate()} value="Update" />
    </div>
  )
  }

}

export default EditSender;