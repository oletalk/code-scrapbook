import { NavType, DocumentInfo, SenderInfo, AccountInfo, DocumentType,
  emptyDocument, emptyAccount, emptySender } from '../common/types-class'
import { useCallback, useEffect, useState } from 'react'
import SelectBox from '../components/SelectBox'
import { BACKEND_URL, fetchSenderAccountsUrl } from '../common/constants'

import { doFetch } from '../common/fetch'

import Nav from "../components/Nav"
import AccountSelectBox from '../components/AccountSelectBox'

function CreateDocument () {
  const [ documentInfo, setDocumentInfo ] = useState<DocumentInfo>(emptyDocument())
  const [ senderList, setSenderList ] = useState<SenderInfo[]>()
  const [ docTypeList, setDocTypeList ] = useState<DocumentType[]>()
  const [ accountList, setAccountList ] = useState<AccountInfo[]>()

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

const addDocument = () => {
  console.log('saving new document')
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


          <div>Document Type:</div>
          <div>
            <SelectBox<DocumentType> 
              itemList={docTypeList}
              selectedItem={documentInfo.doc_type.id}
              selectName='docTypeList'
              changeCallback={(id) => changeDocTypeId(id)}
              noItemMessage="no doc types available" />
          </div>

          <div>Sender:</div>
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

          <div>Summary:
          <input name="summary" className='sender_field' />
          </div>

        </td>
        <td>
          <table className='dates'>
            <tr>
              <td><label>Received</label> *</td><td>
                <input className='sender_field mandatory' type="date" id='date_received' name="received_date" /></td>
            </tr>
            <tr>
              <td><label>Date Due</label></td><td>
                <input className='sender_field' type="date" name="due_date"/></td>
            </tr>
            <tr>
              <td><label>Date Paid</label></td><td>
                <input className='sender_field' type="date" name="paid_date"/></td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>
        <div><label>Receipt photo/PDF:</label></div>
        <div className="advice">(Please save the document first)</div>
        <div><label>Comments:</label></div>
        <div><textarea name='comments' className='sender_field' rows={5}></textarea></div>
        </td>
      </tr>
      <tr>
        <td>
          <button onClick={() => addDocument()}>add document</button>
        </td>        
        </tr>
        </table>
      </div>
    </div>
  )
}

export default CreateDocument