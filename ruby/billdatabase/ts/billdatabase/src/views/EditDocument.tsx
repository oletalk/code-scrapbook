import { useParams, Link } from 'react-router-dom'
import { useCallback, useEffect, useState } from 'react'
import { doFetch } from '../common/fetch'
import FileUploadSection from '../components/FileUploadSection'
import { NavType, DocumentInfo, AccountInfo } from '../common/types-class'
import { fetchSenderAccountsUrl, fetchDocumentUrl } from '../common/constants'
import Nav from '../components/Nav'

interface EditDocumentState {
  changed: boolean
}

function EditDocument() {
  const { id } = useParams<{ id: string }>()
  const [ documentInfo, setDocumentInfo ] = useState<DocumentInfo>()
  const [ accountList, setAccountList ] = useState<AccountInfo[]>()
  const [ state, setState ] = useState<EditDocumentState>({
    changed: false
  })

  const loadSenderAccounts = useCallback((sender_id: string) => {
    console.log('need to load account numbers for sender ' + sender_id) 
    if (sender_id !== 'X') {
      doFetch<AccountInfo[]>(fetchSenderAccountsUrl(sender_id))
      .then((accounts) => {
        setAccountList(accounts)
      })
    }
   }, [])

   const updateDocument = (id : string | undefined) => {
    console.log('updating document ' + id)
    console.log(documentInfo)
   }

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

  const fetchDocument = useCallback((id: number) => {
   // FETCH DOCUMENT INFO
   doFetch<DocumentInfo>(fetchDocumentUrl(id.toString()))
   .then((json) => {
     // let info: DocumentInfo = json as DocumentInfo
     setDocumentInfo(json)
     // fetch document's sender's accounts for dropdown
     console.log('done...') 
     if (typeof json.sender !== 'undefined') {
      return json.sender.id
     }
     return 'X'
   })
   .then((sender_id) => {
    loadSenderAccounts(sender_id)
   })
  }, [loadSenderAccounts])


  const doUpdate = () => {
    if (documentInfo !== undefined)
    console.log('Updating document id ' + documentInfo.id)
  }

  // 'onMounted'...
  useEffect(() => {
    fetchDocument(Number(id))
 
  }, [fetchDocument, id])

if (typeof documentInfo === 'undefined') {
  return (<div>Document info not yet loaded.</div>)
}

  return (
    <div>
      <Nav page={NavType.EditDocument} />
      <div className='layout'>
        <table className='documentdetail'>
          <tr>
            <td className='advice' colSpan={2}>Warning: account numbers are shown in this screen so be careful if you are accessing this site in a public place.</td>
          </tr>
          <tr>
            <td>
              <div>Document Type:</div>
              <div className='field_value'>{documentInfo.doc_type.name}</div>
              
              <div>Sender:</div>
              <div className='field_value'>
                <Link to={'/sender/' + documentInfo.sender.id} >{documentInfo.sender.name}</Link>
              </div>
              
              <div>Sender account:</div>
              <div>
                {accountList && accountList.length > 0 ? 
                <select>
                  <option>Select...</option>
                {accountList?.map((acc) => {
                  return (<option selected={acc.id === documentInfo.sender_account.id} value={acc.id}>{acc.account_number}</option>)
                })}
                </select>
                : <i>No accounts available</i>}
              </div>
              <div>Summary:
                <input name="summary" onChange={(e) => handleDocumentChange({summary: e.target.value})} className='sender_field' value={documentInfo.summary} />
              </div>

            </td>
            <td>
          <table className='dates'>
            <tr>
              <td><label>Received</label> *</td><td><input onChange={(e) => handleDocumentChange({received_date: e.target.value})} className='sender_field mandatory' type="date" id='date_received' name="received_date" value={documentInfo.received_date} /></td>
            </tr>
            <tr>
              <td><label>Date Due</label></td><td><input onChange={(e) => handleDocumentChange({due_date: e.target.value})} className='sender_field' type="date" name="due_date" value={documentInfo.due_date}/></td>
            </tr>
            <tr>
              <td><label>Date Paid</label></td><td><input onChange={(e) => handleDocumentChange({paid_date: e.target.value})} className='sender_field' type="date" name="paid_date" value={documentInfo.paid_date} /></td>
            </tr>
          </table>
        </td>

          </tr>
          <tr>
            <td>
              <FileUploadSection documentInfo={documentInfo} />
        <div><label>Comments:</label></div>
        <div><textarea 
          onChange={(e) => handleDocumentChange({comments: e.target.value})}
          name='comments' 
          className='sender_field' 
          rows={5}>
          {documentInfo.comments}
        </textarea></div>
            </td>
          </tr>
          <tr>
        <td>
          <button onClick={() => updateDocument(documentInfo.id)}>update document</button>
          <Link className={'link-style'} to={'/documents/'} >back to list</Link>
          </td>
        </tr>
        </table>
      </div>              
    </div>
  )
}

export default EditDocument