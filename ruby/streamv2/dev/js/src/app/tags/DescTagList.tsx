import * as React from 'react'
import DescTag from './DescTag'
import LiLink from './LiLink'
import axios from 'axios'

type TagListProps = {
  hash: string
}

type DescriptiveTag = {
  tag_id: number,
  tag_desc: string
}
type TagListState = {
  changed: boolean,
  anyTagsLeft: boolean,
  showTagMenu: boolean,
  songTags: DescriptiveTag[],
  allTags: DescriptiveTag[]
}

export default class DescTagList extends React.Component<TagListProps, TagListState> {
  constructor(props: any) {
    super(props)

    this.fetchTags = this.fetchTags.bind(this)
    this.deleteTag = this.deleteTag.bind(this)
    this.addTag = this.addTag.bind(this)
    this.doPostAction = this.doPostAction.bind(this)
    this.toggleAddTagMenu = this.toggleAddTagMenu.bind(this)
    this.isInSongTags = this.isInSongTags.bind(this)
  }
  state: TagListState = {
    changed: false,
    anyTagsLeft: true,
    showTagMenu: false,
    songTags: [],
    allTags: []
  }
  doPostAction(action: string, tagId: number) {
    console.log('going to ' + action + ' tag id ' + tagId)
    const data = {
      hash: this.props.hash,
      tag_id: tagId
    }
    console.log(data)
    axios.post('/tags/' + action, data)
      .then((response) => {
        console.log(response)
        alert(action + ' on tag was successful!')
      }
      )
      .catch((error) => {
        console.log(error)
      })
      .finally(() => {
        this.fetchTags()
      })
  }
  addTag(tagId: number) {
    this.doPostAction('add', tagId)
    this.setState({ showTagMenu: false })
  }
  toggleAddTagMenu() {
    this.setState({ showTagMenu: !this.state.showTagMenu })
  }
  deleteTag(tagId: number) {
    this.doPostAction('del', tagId)
    this.setState({ showTagMenu: false })
  }

  fetchTags() {
    // fetch all possible tags for adding
    axios.get('/tags/list')
      .then((response) => {
        this.setState({ allTags: response.data })
      })
      .catch((error) => {
        console.log(error)
      })

    // fetch the song's tags
    axios.get('/tags/' + this.props.hash)
      .then((response) => {
        this.setState({ songTags: response.data })
      })
      .catch((error) => {
        console.log(error)
      })
  }
  componentDidMount() {
    this.fetchTags()
  }

  isInSongTags(tag: DescriptiveTag): boolean {
    // const tagids = this.state.songTags.map((t) => { return t.tag_id })
    // console.log(tagids)
    return this.state.songTags
      .map((t) => { return t.tag_id })
      .indexOf(tag.tag_id) != -1
  }

  render() {
    return (
      <div>
        Tags:
        <table className="taglist-container">
          <tbody>
            <tr>
              <td>
                <div className="taglist">
                  {this.state.songTags.map((row) => {
                    return <DescTag
                      key={row.tag_id}
                      tag_id={row.tag_id}
                      tag_desc={row.tag_desc}
                      callback={() => this.deleteTag(row.tag_id)} />
                  })}
                  {this.state.anyTagsLeft
                    && <LiLink text="+" callback={this.toggleAddTagMenu} />}
                </div>
                {this.state.anyTagsLeft
                  && <div className={'tagMenu' + (this.state.showTagMenu ? '' : '-hidden')}>
                    {this.state.allTags.filter((row) => { return !this.isInSongTags(row) }).map((row) => {
                      return <div className='tagMenuItem' key={row.tag_id}>
                        <a className="add-tag-link" href="#" onClick={() => this.addTag(row.tag_id)}>{row.tag_desc}</a>
                      </div>
                    })}
                  </div>}
              </td>
            </tr>
          </tbody>
        </table>
      </div >
    )
  }
}

