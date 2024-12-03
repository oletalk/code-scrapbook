import { doFetch } from '../common/fetch'
import { useCallback, useEffect, useState } from 'react'
import { DocumentInfo } from '../common/types-class'
import { Link } from 'react-router-dom';
import { BACKEND_URL } from '../common/constants'

type SenderDocumentListProps = {
  sender_id: string
}

function SenderDocuments(props: SenderDocumentListProps) {

  const [ documents, setDocuments ] = useState<DocumentInfo[]>()

  const fetchDocuments = useCallback(() => {
    const s_id = props.sender_id
    doFetch<DocumentInfo[]>(BACKEND_URL + '/json/sender/' + s_id + '/documents')
    .then((docs) => {
      setDocuments(docs)
    })
  }, [props.sender_id])

  useEffect(() => {
    fetchDocuments()
  }, [fetchDocuments])

  if (typeof documents !== 'undefined' && documents.length > 0) {
    return (
      <div className='senderDocumentList'>
        <ul>
        {documents?.map(d => 
          (<li><span><Link to={'/document/' + d.id}>{d.received_date}</Link> - </span><span>{d.summary}</span></li>)
        )}
        </ul>
      </div>
    )
  } else {
    return (<div className='senderDocumentListNone'>No documents from sender</div>)
  }
}

export default SenderDocuments