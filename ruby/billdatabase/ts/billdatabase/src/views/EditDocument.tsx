import { useParams, Link } from 'react-router-dom'
import { useEffect, useState } from 'react'
import { doFetch } from '../common/fetch'
import { NavType, DocumentInfo } from '../common/types-class'
import { BACKEND_URL, fetchSenderUrl } from '../common/constants'
import Nav from '../components/Nav'

function EditDocument() {
  const { id } = useParams()
  const [ documentInfo, setDocumentInfo ] = useState<DocumentInfo>()
  useEffect(() => {

    // FETCH DOCUMENT INFO
      doFetch<DocumentInfo>(BACKEND_URL + '/document/' + id)
      .then((json) => {
        // let info: DocumentInfo = json as DocumentInfo
        setDocumentInfo(json)
      })
}, [id])



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
              <div className='field_value'>{documentInfo?.doc_type.name}</div>
              
              <div>Sender:</div>
              <div className='field_value'>
                <Link to={'/sender/' + documentInfo?.sender.id} >{documentInfo?.sender.name}</Link>
              </div>
              
              <div>Sender account:</div>
              <div>
                TODO
              </div>

            </td>
          </tr>
        </table>
      </div>              
    </div>
  )
}

export default EditDocument