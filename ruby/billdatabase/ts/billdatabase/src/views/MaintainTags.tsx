import { TagObject } from '../common/types-class'
import React from "react";

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
    fetch('http://localhost:4567/taglist')
    .then((response) => {
    // Check if the request was successful
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
        return response.json()
      })
      .then((json) => {
        let setTags = json as TagObject[]
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

    fetch('http://localhost:4567/tagtype/' + tagId, {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
    },
    body: JSON.stringify({
      color: tagColor
    })
  })
  .then((response) => {
    // Check if the request was successful
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
        return response.json()
      })
      // wait a second for the update
      setTimeout(() => this.fetchTags(), 1000)
      
  }

  render() {
    return (
      <div className="App">
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