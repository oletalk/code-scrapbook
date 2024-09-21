import { TagObject } from '../common/types-class'
import * as Constants from '../common/constants'
import { doDelete, doPost } from '../common/fetch'
import { useState } from 'react'

interface TagListProps {
  sender_id: string,
  info: TagObject[],
  taglist: TagObject[]
}

interface TagListState {
  showTagList: boolean
}



function EditTagList (props: TagListProps) {
  const sender = props.sender_id
  const tags = props.info
  const taglist = props.taglist

  const [ state, setState ] = useState<TagListState>({
    showTagList: false
  })

  const reloadScreen = () => {
    window.location.reload()
  }

  const delTag = (sender: string, id: string) => {
    console.log('deleting tag ' + id)
    const url = Constants.updateSenderTagUrl(sender, id)
    doDelete(url, reloadScreen)
  }

  const addTag = (sender: string, id: string) => {
    console.log('adding tag ' + id)
    const url = Constants.updateSenderTagUrl(sender, id)
    doPost(url, {}, true, reloadScreen, 'adding tag')
    // setState({showTagList: false})
  }


  const toggleTagMenu = (senderid: string) => {
    setState({
      ...state,
      showTagList: !state.showTagList
    })
  }

  return (
    <div>
    <div id='sendertags' className='taglist'>
      {tags.map(tag => 
        <button onClick={() => delTag(sender, tag.id)}>{tag.description}</button>
      )}
    </div>
    <button onClick={() => toggleTagMenu(props.sender_id)} id='addbutton'>
      <i> (add)</i>
    </button>
    <ul id='taglist' className={state.showTagList ? '' : 'hidden'}>
     {taglist.map(tag => 
      <li onClick={() => addTag(props.sender_id, tag.id)}>{tag.description}</li>
     )}
    </ul>
    </div>
    
  )
}

export default EditTagList;