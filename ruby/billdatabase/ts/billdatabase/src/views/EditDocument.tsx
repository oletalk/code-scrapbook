import { useParams, Link } from 'react-router-dom'
import { useCallback, useEffect, useState } from 'react'
import { doFetch, doPost } from '../common/fetch'
import FileUploadSection from '../components/FileUploadSection'
import { NavType, DocumentInfo, 
  AccountInfo, Common, adaptedDocInfoFields } from '../common/types-class'
import AccountSelectBox from '../components/AccountSelectBox'
import EditField from '../components/EditField'
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
    if (typeof id !== 'undefined' && typeof documentInfo !== 'undefined') {
      console.log('updating document ' + id)
      console.log(adaptedDocInfoFields(documentInfo))
      const url = fetchDocumentUrl(id)
      doPost(url, adaptedDocInfoFields(documentInfo),
        true, postUpdate, 'updating document')
 
    }
  }

  const postUpdate = () => {
    window.location.reload()
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

  const changeSenderAccountId = (id : AccountInfo | undefined) => {
    console.log('TODO changeSenderAccountId to ' + id?.account_number)
  }
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
              <AccountSelectBox 
                  selectName="sender_account" 
                  selectedItem={documentInfo.sender_account?.id}
                  changeCallback={(id) => changeSenderAccountId(id)}
                  itemList={accountList} 
                  noItemMessage="sender not selected" />
              </div>
              <div>Summary:
              <EditField 
              initialValue={documentInfo.summary}
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
                  initialValue={documentInfo.received_date}
                  fieldType="date"
                  fieldName="received_date"
                  changeCallback={handleDocumentChange}
                />
              </td>
            </tr>
            <tr>
              <td><label>Date Due</label></td><td>
              <EditField 
                  initialValue={documentInfo.due_date}
                  fieldType="date"
                  fieldName="due_date"
                  changeCallback={handleDocumentChange}
                /></td>
            </tr>
            <tr>
              <td><label>Date Paid</label></td><td>
              <EditField 
                  initialValue={documentInfo.paid_date}
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
              <FileUploadSection documentInfo={documentInfo} />
        <div><label>Comments:</label></div>
        <div><EditField 
                  initialValue={documentInfo.comments}
                  fieldType="textarea"
                  fieldName="comments"
                  changeCallback={handleDocumentChange}
                /></div>
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