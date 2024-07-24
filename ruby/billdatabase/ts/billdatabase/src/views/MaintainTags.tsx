import { TagObject, NavType } from '../common/types-class'
import React from "react"
import { doFetch, doPost } from '../common/fetch'
import * as Constants from '../common/constants'
import Nav from '../components/Nav'
import { BACKEND_URL } from '../common/constants'


type TagProps = {

}
type TagState = {
  tags: TagObject[]
}


export default class MaintainTags extends React.Component<TagProps,TagState> {
  constructor(props: any) {
    super(props)

    this.recordChange = this.recordChange.bind(this)
    this.updateColor = this.updateColor.bind(this)
    // this.fetchTags = this.fetchTags.bind(this)
    this.fetchTags()
  }

  state: TagState = {
    tags: []
  }

  fetchTags = () => {
    console.log('fetching up-to-date tag data.')
    doFetch<TagObject[]>(Constants.BACKEND_URL + '/taglist')
      .then((json) => {
        let setTags = json
        setTags.forEach(t => {
          t.changed = false
        })
        this.setState({
          tags: setTags
        })
      })
  }

  recordChange = (tagId: string, newColor: string) => {
    const newState = [...this.state.tags]

    newState.map(tag => {
      if (tag.id === tagId) {
        tag.changed = true
        tag.color = newColor
        return tag
      } else {
        return tag
      }
    })

    this.setState({
       tags: newState
    })    
  }

  updateColor = (tagId: string, tagColor: string) => {
    console.log(tagId + ' to be updated with colour ' + tagColor)
    // update in db

    doPost(BACKEND_URL + '/tagtype/' + tagId, 
      { color: tagColor },
      true, this.fetchTags, 're-fetching tags'
    )
      
  }

  render() {
    return (
      <div className="App">
        <Nav page={NavType.TagTypes} />
        <table className="tags">
          <tbody>
          {this.state.tags.map(tag => {
               return <tr key={tag.id}>
                  <td>
                    <input className='fieldval' 
                           onChange={(e) => this.recordChange(tag.id, e.target.value)}
                           type='color' value={tag.color || '#000000'}/> {tag.description}
                  </td>
                  <td>
                    <input disabled={!tag.changed }type='button' onClick={() => this.updateColor(tag.id, tag.color)}  value={tag.changed ? 'update' : '(not changed)'}/>
                  </td>
              </tr>
        })}
                  </tbody>
        </table>
        Refresh the page to abandon all unsaved changes.
    </div>
    )
  }
}