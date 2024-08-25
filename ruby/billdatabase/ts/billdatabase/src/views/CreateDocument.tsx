import { NavType, DocumentInfo, SenderInfo, AccountInfo, DocumentType,
  emptyDocument, emptyAccount } from '../common/types-class'
import { useCallback, useEffect, useState } from 'react'
import SelectBox from '../components/SelectBox'
import EditField from '../components/EditField'
import { BACKEND_URL, fetchSenderAccountsUrl } from '../common/constants'

import { doFetch } from '../common/fetch'

import Nav from "../components/Nav"
import AccountSelectBox from '../components/AccountSelectBox'

interface EditDocumentState {
  changed: boolean
}

function CreateDocument () {
  const [ documentInfo, setDocumentInfo ] = useState<DocumentInfo>(emptyDocument())
  const [ senderList, setSenderList ] = useState<SenderInfo[]>()
  const [ docTypeList, setDocTypeList ] = useState<DocumentType[]>()
  const [ accountList, setAccountList ] = useState<AccountInfo[]>()
  const [ state, setState ] = useState<EditDocumentState>({
    changed: false
  })

  /* TODO: change dependency to documentInfo.sender.id */
  const loadSenderAccounts = useCallback((sender_id: string | undefined) => {
    if (sender_id !== undefined) {
      console.log('need to load account numbers for sender ' + sender_id) 
      if (sender_id !== 'X') {
        doFetch<AccountInfo[]>(fetchSenderAccountsUrl(sender_id))
        .then((accounts) => {
          setAccountList(accounts)
        })
      }
    }

   }, [])

const loadAllSenders = useCallback(() => {
  doFetch<SenderInfo[]>(BACKEND_URL + '/senders')
  .then((json) => {
    console.log(json)
    setSenderList(json)
  })
}, [])

const loadAllDocTypes = useCallback(() => {
  doFetch<DocumentType[]>(BACKEND_URL + '/doctypes')
  .then((json) => {
    console.log(json)
    setDocTypeList(json)
  })
}, [])

const changeSenderId = (newsender : SenderInfo | undefined) => {
  if (documentInfo !== undefined && newsender !== undefined) {
    console.log('sender id is now ' + newsender)
    // let newSender : SenderInfo = emptySender()
    let newSenderAccount : AccountInfo = emptyAccount()
    // newSender.id = newid

    setDocumentInfo({
      ...documentInfo,
      sender: newsender,
      sender_account: newSenderAccount
    })
    loadSenderAccounts(newsender.id)
  }

}

const changeDocTypeId = (newtype : DocumentType | undefined) => {
  if (documentInfo !== undefined && newtype !== undefined) {
    console.log('document doc type is now ' + newtype)
    documentInfo.doc_type = newtype
  }
}

  // check mandatory fields - doc type, sender, summary, received
  const mandatoryFieldsMissing = useCallback(() : boolean => {
  // console.log('mandatory fields missing check...')
    let missingFields = true
  if (documentInfo !== undefined) {
    if (documentInfo.doc_type.id 
      && documentInfo.sender.id
      && documentInfo.summary
      && documentInfo.received_date 
    ) {
      missingFields = false
    }
  }
  return missingFields
}, [documentInfo])

const handleDocumentChange = (kv: Object) => {
  setDocumentInfo({
    ...documentInfo,
    ...kv
  } as DocumentInfo)
  setState({
    ...state,
    changed: true
  })
 }

const addDocument = () => {
  console.log(documentInfo)

}
const changeSenderAccountId = (newsenderaccount : AccountInfo | undefined) => {
  if (documentInfo !== undefined && newsenderaccount !== undefined) {
    console.log('sender account id is now ' + newsenderaccount)
    // let newAccount : AccountInfo = emptyAccount()
    // newAccount.id = newid
      
    setDocumentInfo({
      ...documentInfo,
      sender_account: newsenderaccount
    }
    )
  }
}

   // 'onMounted'
   useEffect(() => {
    loadAllSenders()
    loadAllDocTypes()
   }, [loadAllSenders, loadAllDocTypes])

  return (
    <div>
      <Nav page={NavType.NewDocument} />
      <h2>Add New Document</h2>
      <div className="layout">
        <table className="documentdetail">
        <tr>
      <td className='advice' colSpan={2}>Warning: account numbers are shown in this screen so be careful if you are accessing this site in a public place.</td>
      </tr>
      <tr>
        <td>


          <div>Document Type: *</div>
          <div>
            <SelectBox<DocumentType> 
              itemList={docTypeList}
              selectedItem={documentInfo.doc_type.id}
              selectName='docTypeList'
              changeCallback={(id) => changeDocTypeId(id)}
              noItemMessage="no doc types available" />
          </div>

          <div>Sender: *</div>
          <div>
          <SelectBox<SenderInfo> 
                itemList={senderList} 
                selectedItem={documentInfo?.sender.id}
                selectName="senderList" 
                changeCallback={(id) => changeSenderId(id)}
                noItemMessage="no senders available" />
          </div>
          <div>Sender account:</div>
          <div>
            <AccountSelectBox 
                  selectName="sender_account" 
                  selectedItem={documentInfo?.sender_account.id}
                  changeCallback={(id) => changeSenderAccountId(id)}
                  itemList={accountList} 
                  noItemMessage="sender not selected" />
          </div>

          <div>Summary: *
          <EditField 
              fieldType="text"
              fieldName="summary" 
              changeCallback={(val) => handleDocumentChange(val)}/>
          </div>

        </td>
        <td>
          <table className='dates'>
            <tr>
              <td><label>Received</label> *</td><td>
                <EditField 
                  fieldType="date"
                  fieldName="received_date"
                  changeCallback={handleDocumentChange}
                />
              </td>
            </tr>
            <tr>
              <td><label>Date Due</label></td><td>
              <EditField 
                  fieldType="date"
                  fieldName="due_date"
                  changeCallback={handleDocumentChange}
                /></td>
            </tr>
            <tr>
              <td><label>Date Paid</label></td><td>
              <EditField 
                  fieldType="date"
                  fieldName="paid_date"
                  changeCallback={handleDocumentChange}
                /></td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>
        <div><label>Receipt photo/PDF:</label></div>
        <div className="advice">(Please save the document first)</div>
        <div><label>Comments:</label></div>
        <div><EditField 
                  fieldType="textarea"
                  fieldName="comments"
                  changeCallback={handleDocumentChange}
                /></div>
        </td>
      </tr>
      <tr>
        <td>
          <button disabled={mandatoryFieldsMissing()} onClick={() => addDocument()}>add document</button>
        </td>        
        </tr>
        </table>
      </div>
    </div>
  )
}

export default CreateDocument