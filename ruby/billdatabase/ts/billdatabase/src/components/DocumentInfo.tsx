import { AccountInfo, DocumentInfo } from "../common/types-class"
import { Link } from 'react-router-dom';

interface DocumentInfoProps {
  colour: string,
  index: number,
  info: DocumentInfo,
  format?: string,
  closeCallback?: () => void,
}

function ViewDocumentInfo({
  colour,
  index,
  info,
  format = "default",
  closeCallback = () => {}
}: DocumentInfoProps) {


  function textcolour(c: string) {
    return (c === '') ? 'black' : c
  }
  function background(index: number) {
    return (index % 2 === 0 ? 'bkg_1' : 'bkg_2')
  }
  function dateornull(dte: string) {
    return (dte ? dte : '-')
  }

  function isnotblank(dte: string) {
    if (typeof dte === 'undefined') {
      return false;
    }
    if (dte == null) {
      return false;
    }
    if (dte.trim() === '' || dte === '-') {
      return false;
    }
    return true;
  }

  function accountNumOrSpace(ac: AccountInfo) {
    return ac ? ac.account_number : '&nbsp;'
  }
  if (format === 'compact') {
    return (
      <div style={{color: textcolour(colour)}} className="compactDocumentInfo">
        <div className="compactCloseButton"><button onClick={closeCallback}>X</button></div>
        <div ><b>DOCUMENT DETAILS</b></div>
        <div>{info.summary}</div>
        <div className='date_rcvd'>
        <Link title="view/edit document" to={'/document/' + info.id}>{info.received_date}</Link> {info.doc_type.name} <i>from</i> <Link title="view/edit sender" to={"/sender/" + info.sender.id }>{info.sender.name}</Link>

        </div>
        {isnotblank(info.due_date) ? <div className='date_rcvd'>Due {dateornull(info.due_date)} Paid {dateornull(info.paid_date)}</div> : <div>&nbsp;</div>}
  
      </div>
    )  
  } else { /* NORMAL VIEW */
    return (
      <div style={{color: textcolour(colour)}} className={background(index)}>
        <span className='date_rcvd'>
        <Link to={'/document/' + info.id}>{info.received_date}</Link>
        </span>
        <span className='doc_type'>{info.doc_type.name}</span>
        <span className='doc_sender'>
        <Link to={"/sender/" + info.sender.id }>{info.sender.name}</Link>
        
        </span>
        <span className='date_rcvd'>{dateornull(info.due_date)}</span>
        <span className='date_rcvd'>{dateornull(info.paid_date)}</span>
        <span className='doc_account accountnumber'>{accountNumOrSpace(info.sender_account)}</span>
        <span className='doc_summary'>{info.summary}</span>
  
      </div>
    )
  
  }
}

export default ViewDocumentInfo;