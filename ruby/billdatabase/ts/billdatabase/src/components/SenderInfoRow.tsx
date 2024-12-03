import { senderbox } from "../common/types-class"
import { useState } from "react"
import SenderDocuments from "./SenderDocuments"
import { Link } from 'react-router-dom'

// state kept here for the expanded property...
interface SenderInfoState {
  expanded: boolean,
  changed: boolean,
  filtered: boolean
}

function SenderInfoRow (props: senderbox) {
  const sbox = props
  const [ rowState, setRowState ] = useState({
    expanded: false,
    changed: false,
    filtered: false
  })


  /*
    // TODO : better retrieval of this point
  const isFiltering = (tagid: string) : boolean => {

  */
// ----

  const toggleExpand = () => {
      const exp = !rowState.expanded
      setRowState({
        ...rowState,
        expanded: exp
      })
  }

// -----


    return (
      <tr className={sbox.filtered ? 'tr-hide' : 'tr-show'} key={sbox.info.id}>
                    <td>
                    <div>
                        <input className='senderBtnToggle' type='button' onClick={toggleExpand} value=" + " />
                       <Link to={"/sender/" + sbox.info.id }>{sbox.info.name}</Link>
  
                      </div>
                      <div className={rowState.expanded ? 'sender-expanded' : 'sender-collapsed'} >
                        <div>
                        <label>Username</label><span className='optional'> (optional): </span>
                        { sbox.info.username !== '' ? sbox.info.username : 'N/A' }
                        </div>
                        <div className="tooltip">
                        <label>Password hint:</label>
                        <span className='tooltiptext'>{ sbox.info.password_hint }</span>
                        </div>
                        <div>
                        <SenderDocuments sender_id={sbox.info.id} />
                        </div>
                      </div>
                    </td>
                </tr>
    )
  
  
}

export default SenderInfoRow;