import Nav from "../components/Nav"
import { NavType, Common, SenderInfo, emptySender } from '../common/types-class'
import { useState, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import * as Constants from '../common/constants'
import EditField from "../components/EditField"
import { doPostAndReturn } from "../common/fetch"


interface EditSenderState {
  changed: boolean
}

function CreateSender() {
  const navigate = useNavigate()
  const [ senderInfo, setSenderInfo ] = useState<SenderInfo>(emptySender())
  const [ state, setState ] = useState<EditSenderState>({
    changed: false
  })

  const addSender = () => {
    console.log('saving sender info')
    const url = Constants.saveNewSenderUrl()
    doPostAndReturn<Common>(url, senderInfo)
    .then((response) => {
      if (response !== undefined && response.id !== undefined) {
        // redirect to editing newly created sender
        navigate('/sender/' + response.id)
      }
    })
  
  }
  /*
  can i put this into a library somewhere?

   need the base type = SenderInfo
   and the callback for useState 'set' = setSenderInfo
   and the callback for useState 'get' = senderInfo
  */
  const handleSenderChange = (kv: Object) => {
    setSenderInfo({
      ...senderInfo,
      ...kv
    } as SenderInfo)
    setState({
      ...state,
      changed: true
    })
   }

   const mandatoryFieldsMissing = useCallback(() : boolean => {
    let missingFields = true
    if (senderInfo !== undefined) {
      if (senderInfo.name) {
        missingFields = false
      }
    }
    return missingFields
   }, [senderInfo])

  return (
    <div>
            <Nav page={NavType.NewSender} />
            <h2>Add New Sender</h2>
            <div className="layout" id="doctype_section">
      <table className="senderdetail">
      <tr>
        <td><label>Name:</label> *</td><td colSpan={3}>
          <b>
            <EditField
                fieldType="text"
                fieldName="name"
                mandatory
                changeCallback={handleSenderChange} 
            />
          </b>
          </td>
      </tr>
      <tr>
        <td><label>Username</label><span className='optional'> (optional)</span></td>
        <td colSpan={2}>
          <EditField 
              fieldType="text"
              fieldName="username"
              changeCallback={handleSenderChange}
          />
        </td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td><label>Password hint</label><span className='optional'> (optional)</span></td>
        <td colSpan={2}>
        <EditField 
              fieldType="text"
              fieldName="password_hint"
              changeCallback={handleSenderChange}
          />
        </td>
        <td>&nbsp;</td>
      </tr>
          <tr>
            <td colSpan={4}>
              <div className='sender_account' >
                <div>
                (Save sender first before adding accounts)
                </div>
              </div>
            </td>
          </tr>
          <tr>
            <td colSpan={4}>
              <div className='sender_contact' >
                <div>
                (Save sender first before adding contact information)
                </div>
              </div>
            </td>
          </tr>

      <tr>
        <td><label>Comments</label></td><td colSpan={3}>
        <EditField 
              fieldType="textarea"
              fieldName="comments"
              changeCallback={handleSenderChange}
          />
          </td>
      </tr>
      <tr>
        <td colSpan={4}>
          <button disabled={mandatoryFieldsMissing()} onClick={addSender}>add sender</button>
        </td>
        </tr>
      </table>
    </div>    
  </div>
  )
}

export default CreateSender