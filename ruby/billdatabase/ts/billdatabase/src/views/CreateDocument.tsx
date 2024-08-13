import { NavType, DocumentInfo, SenderInfo, AccountInfo, 
  emptyDocument, emptyAccount, emptySender } from '../common/types-class'
import { useCallback, useEffect, useState } from 'react'
import SelectBox from '../components/SelectBox'
import { BACKEND_URL, fetchSenderAccountsUrl } from '../common/constants'

import { doFetch } from '../common/fetch'

import Nav from "../components/Nav"
import AccountSelectBox from '../components/AccountSelectBox'
import { idText } from 'typescript'

function CreateDocument () {
  const [ documentInfo, setDocumentInfo ] = useState<DocumentInfo>(emptyDocument())
  const [ senderList, setSenderList ] = useState<SenderInfo[]>()
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

const changeSenderId = (newid : string) => {
  if (documentInfo !== undefined && documentInfo.sender !== undefined) {
    console.log('sender id is now ' + newid)
    let newSender : SenderInfo = emptySender()
    let newSenderAccount : AccountInfo = emptyAccount()
    newSender.id = newid

    setDocumentInfo({
      ...documentInfo,
      sender: newSender,
      sender_account: newSenderAccount
    })
    loadSenderAccounts(newid)
  }

}

const changeSenderAccountId = (newid : string) => {
  if (documentInfo !== undefined && documentInfo.sender !== undefined) {
    console.log('sender account id is now ' + newid)
    let newAccount : AccountInfo = emptyAccount()
    newAccount.id = newid
      
    setDocumentInfo({
      ...documentInfo,
      sender_account: newAccount
    }
    )
  }
}

   // 'onMounted'
   useEffect(() => {
    loadAllSenders()
   }, [loadAllSenders])

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
            <select className='sender_field mandatory' id="doctypes" name="doc_type_id">
            <option value=''> - Please select - </option>
            </select>
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
        </table>
      </div>
    </div>
  )
}

export default CreateDocument