import { AccountInfo, DocumentInfo } from "../common/types-class"
import { Link } from 'react-router-dom';

interface DocumentInfoProps {
  colour: string,
  index: number,
  info: DocumentInfo
}

function ViewDocumentInfo(props: DocumentInfoProps) {
  const index = props.index
  const info = props.info

  function textcolour(c: string) {
    return (c === '') ? 'black' : c
  }
  function background(index: number) {
    return (index % 2 === 0 ? 'bkg_1' : 'bkg_2')
  }
  function dateornull(dte: string) {
    return (dte ? dte : '-')
  }

  function accountNumOrSpace(ac: AccountInfo) {
    return ac ? ac.account_number : '&nbsp;'
  }
  // TODO these should all be fixed-width as if they were in a table!
  return (
    <div style={{color: textcolour(props.colour)}} className={background(index)}>
      <span className='date_rcvd'>
      <Link to={'/document/' + props.info.id}>{info.received_date}</Link>
      </span>
      <span className='doc_type'>{props.info.doc_type.name}</span>
      <span className='doc_sender'>{props.info.sender.name}</span>
      <span className='date_rcvd'>{dateornull(props.info.due_date)}</span>
      <span className='date_rcvd'>{dateornull(props.info.paid_date)}</span>
      <span className='doc_account accountnumber'>{accountNumOrSpace(props.info.sender_account)}</span>
      <span className='doc_summary'>{props.info.summary}</span>

    </div>
  )
}

export default ViewDocumentInfo;