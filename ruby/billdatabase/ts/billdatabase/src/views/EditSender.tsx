import { useState, useEffect, useCallback } from 'react'
import { doFetch, doPostAndReturnMessage } from '../common/fetch'
import { NavType } from '../common/types-class'
import { useParams } from 'react-router-dom'
import TabbedDisplay from '../components/TabbedDisplay'
import EditField from '../components/EditField'
import Nav from '../components/Nav'

import { SenderInfo, TagObject, AccountInfo, ContactInfo, ListUtils,
  emptyAccount, emptyContact
  } from '../common/types-class'
import { BACKEND_URL, fetchSenderUrl } from '../common/constants'
import EditAccountInfo from '../components/AccountInfo'
import EditContactInfo from '../components/ContactInfo'
import ViewSenderNotes from '../components/ViewSenderNotes'
import EditTagList from '../components/TagInfo'

interface EditSenderState {
  changed: boolean,
  saveTs: number,
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
      json_class: '', id: '', name: '', is_active: true, created_at: new Date(), 
      username: '', password_hint: '', comments: '', 
      sender_accounts: [], sender_contacts: [], sender_tags: []
  })
  const [ state, setState ] = useState<EditSenderState>(
    {
      changed: false,
      saveTs: new Date().getTime(),
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

  const doUpdate = () => {
    // do update, POST etc
    if (state.changed) {
      console.log('Saving sender info')
    }
    if (typeof id !== 'undefined') {
      console.log('Updating sender id ' + id)
      console.log(sender)
      // TODO save top-level sender info POST /sender/:id
      const data = {
        username: sender.username,
        password_hint: sender.password_hint,
        comments: sender.comments,
        is_active: sender.is_active ? 'Y' : 'N'
      }
      doPostAndReturnMessage(fetchSenderUrl(id), data)
      .then((res) => {
        setState({...state, changed: false})
      }).catch((err) => {
        console.log(err)
        alert(err)
      })
  
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

  const nonEmpty = (str : string) : boolean => {
    if (str.length === 0) {
      return false
    }
    if (str.match(/^\s+$/)) {
      return false
    }
    return true
  }

  const getTagList = useCallback(() => {
    console.log('fetching full tag list...')
    doFetch<TagObject[]>(BACKEND_URL + '/tags')
      .then((json) => {
        setTagMenu(json)
      })
  }, [])
  
  // confusing advice on using useEffect... or not?
  // https://react.dev/learn/you-might-not-need-an-effect

  useEffect(() => {
    getTagList()

    if (typeof id === 'undefined') {
      return
    }
    console.log('fetching sender data.')

    doFetch<SenderInfo>(fetchSenderUrl(id))
      .then((json) => {
        // fix the boolean fields
        let x = json
        setSender(x)
        setState({...state, changed: false})
      })
    }, [])

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
    /* DEFINE CONTENT FOR EACH OF THE TABS */
    // general, accounts, contacts
    const tabContent : JSX.Element[] =
      [<table className={sender.is_active ? 'tabContent' : 'tabContent tabInactive'}>
        <tr>      
          {/* ---- GENERAL SENDER INFO ---- */}
          <td colSpan={4}>
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
          <EditField 
            initialValue={sender.username}
            fieldType="text"
            fieldName="username"
            changeCallback={handleSenderChange}
        />
          </td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>
            <label>Password hint</label>
            <span className='optional'> (optional): </span>
          </td>
          <td colSpan={2}>
          <EditField 
            initialValue={sender.password_hint}
            fieldType="text"
            fieldName="password_hint"
            changeCallback={handleSenderChange}
        />
          </td>
          <td>&nbsp;</td>
        </tr>
        <tr>
        <td><label>Comments</label></td><td colSpan={3}>
        <EditField 
            initialValue={sender.comments}
            fieldType="textarea"
              fieldName="comments"
              changeCallback={handleSenderChange}
          />
          </td>
      </tr>
      <tr>
        <td colSpan={4}>
          <td><label htmlFor="is_active">Active?</label> <input name="is_active" onClick={() => handleSenderChange({...sender, 'is_active': !sender.is_active})} type='checkbox' checked={sender.is_active}></input>
          </td>
        </td>
      </tr>
      </table>, 


    <table className='tabContent'>
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
      </table>, 
      

      <table className='tabContent'>
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
    </table>]
    /* END TABBED CONTENT */
    
    return (
      <div>
        <Nav page={NavType.EditSender} />
        <div>
          <TabbedDisplay 
            tabs={[{ name: 'General', content: tabContent[0], nonEmpty: (nonEmpty(sender.username) || nonEmpty(sender.password_hint) || nonEmpty(sender.comments)) },
                   { name: 'Accounts', content: tabContent[1], nonEmpty: sender.sender_accounts.length > 0 },
                   { name: 'Contacts', content: tabContent[2], nonEmpty: sender.sender_contacts.length > 0  }]
            }
            headerContent={<span className='sendername'>{ sender.name} {sender.is_active ? '' : ' (inactive)'}</span>}
          />

        </div>
        <div>        
          <input type="button" disabled={!state.changed} onClick={() => doUpdate()} value="Update" />
        </div>
        <div>
          <ViewSenderNotes sender_id={sender.id}/>
        </div>
    
    
    </div>
  )
  }

}

export default EditSender;