import * as React from 'react'
import DescTag from './DescTag'
import LiLink from './LiLink'
import TagMenu from './TagMenu'
import axios from 'axios'
import { TagObject } from '../list/js/playlist_util_t'

type TagListProps = {
  hash: string
}

type TagListState = {
  changed: boolean,
  anyTagsLeft: boolean,
  showTagMenu: boolean,
  songTags: TagObject[],
  allTags: TagObject[]
  tagMenuTitle: string,
  message: string
}

export default class DescTagList extends React.Component<TagListProps, TagListState> {
  constructor(props: any) {
    super(props)

    this.fetchTags = this.fetchTags.bind(this)
    this.deleteTag = this.deleteTag.bind(this)
    this.addTag = this.addTag.bind(this)
    this.doPostAction = this.doPostAction.bind(this)
    this.toggleAddTagMenu = this.toggleAddTagMenu.bind(this)
  }
  state: TagListState = {
    changed: false,
    anyTagsLeft: true,
    showTagMenu: false,
    songTags: [],
    allTags: [],
    tagMenuTitle: '+',
    message: ''
  }

  get newTagName(): string {
    return this.state.showTagMenu ? '-' : '+'
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
        // alert(action + ' on tag was successful!')
        this.setState({ message: action + ' on tag was successful!' })
        const a = this
        setTimeout(() => {
          a.setState({ message: '' })
        }, 2000)
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
    this.setState({
      tagMenuTitle: this.newTagName,
      showTagMenu: !this.state.showTagMenu
    })
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
                    && <LiLink title="add tag" text={this.newTagName} callback={this.toggleAddTagMenu} />}
                </div>
                {this.state.anyTagsLeft
                  && <TagMenu
                    songTags={this.state.songTags}
                    allTags={this.state.allTags}
                    showMenu={this.state.showTagMenu}
                    addTagCallback={this.addTag} />}
              </td>
            </tr>
          </tbody>
        </table>
        {this.state.message
          && <span className="taglist-message">{this.state.message}</span>
        }
      </div >
    )
  }
}