import { SenderNote } from "../common/types-class"
import { useState, useEffect, useCallback } from "react"
import { doFetch, doPostAndReturnMessage } from "../common/fetch"
import { fetchSenderNotesUrl, saveNewSenderNoteUrl } from "../common/constants"
import { displayDate } from "../common/types"
type SenderNotesInfo = {
  sender_id: string
}

function ViewSenderNotes(props: SenderNotesInfo) {

  const [ senderNotes, setSenderNotes ] = useState<SenderNote[]>()
  const [ newNote, setNewNote ] = useState<string>()
  const noteInfo = {
    'notes': newNote,
    'sender_id': props.sender_id
  }

  const addNote = () => {
    console.log('adding note content ' + newNote)

      doPostAndReturnMessage(saveNewSenderNoteUrl(props.sender_id), noteInfo)
      .then(() => 
        getSenderNotes()
      )
      .catch((e) => {
      alert(e)
    })      
  }

  const getSenderNotes = useCallback(() => {
    setNewNote('')
    const s_id = props.sender_id
    if (typeof s_id !== 'undefined' && s_id.length > 0) {
      console.log('fetching sender notes...')
    doFetch<SenderNote[]>(fetchSenderNotesUrl(props.sender_id))
      .then((json) => {
        setSenderNotes(json)
      }) 
    }
   
  }, [props.sender_id])

  useEffect(() => {
    getSenderNotes()
  }, [getSenderNotes])

  // TODO: need to refresh screen post-save

  if (typeof senderNotes !== 'undefined' && senderNotes.length > 0) {
    return (
      <div>
        <ul className="senderNotes">{senderNotes.map((sn) => (
        <li><span className="dispDate">{displayDate(sn.created_at)}</span> : <span className="dispNote">{sn.notes}</span></li>
      ))}
          <li><input value={newNote} onChange={(e) => {setNewNote(e.target.value)}} placeholder="add a note..."></input>          <button onClick={addNote}>Add Note</button>
          </li>
        </ul>
      </div>
    )  
  } else {
    return (    
    <div>
        <ul className="senderNotes">
          <li><input value={newNote} onChange={(e) => {setNewNote(e.target.value)}} placeholder="add a note..."></input>          <button onClick={addNote}>Add Note</button>
          </li>
        </ul>

    </div>    )
  }

}

export default ViewSenderNotes