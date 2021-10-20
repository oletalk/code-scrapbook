import * as React from 'react'
import { TagObject } from '../list/js/playlist_util_t'

type TagMenuProps = {
  songTags: TagObject[],
  allTags: TagObject[],
  showMenu: boolean
  // eslint-disable-next-line no-unused-vars
  addTagCallback: (tag_id: number) => void
}

type TagMenuState = {
  anyTagsLeft: boolean,
  filterText: string,
  lotsOfTags: boolean,
}

export default class TagMenu extends React.Component<TagMenuProps, TagMenuState> {
  constructor(props: any) {
    super(props)

    this.isInSongTags = this.isInSongTags.bind(this)
    this.filterText = this.filterText.bind(this)
    this.changeFT = this.changeFT.bind(this)
    this.filteredList = this.filteredList.bind(this)
  }
  state: TagMenuState = {
    anyTagsLeft: true,
    filterText: '',
    lotsOfTags: false,
  }
  finishUp(n: number) {
    this.setState({ filterText: '' })
    this.props.addTagCallback(n)
  }
  changeFT(e: React.FormEvent<HTMLInputElement>) {
    this.setState({ filterText: e.currentTarget.value })
  }
  filterText(str: string): boolean {
    return str.indexOf(this.state.filterText) != -1
  }
  isInSongTags(tag: TagObject): boolean {
    // const tagids = this.state.songTags.map((t) => { return t.tag_id })
    // console.log(tagids)
    return this.props.songTags
      .map((t) => { return t.tag_id })
      .indexOf(tag.tag_id) != -1
  }

  filteredList(): TagObject[] {
    const ret: TagObject[] = this.props.allTags
      .filter((row) => this.filterText(row.tag_desc)) // filter tag names on the text box
      .filter((row) => { return !this.isInSongTags(row) }) // filter on whether the song already has the tag
    return ret
  }
  componentDidMount() {
    // console.log(this.props.allTags)
    // this.setState({ displayList: this.filteredList() })
  }

  render() {
    return (
      <div className={'tagMenu' + (this.props.showMenu ? '' : '-hidden')}>
        <div className='filterTags'><input onChange={this.changeFT} type='text' value={this.state.filterText} /></div>
        {this.filteredList().map((row) => {
          return <div className='tagMenuItem' key={row.tag_id}>
            <a className="add-tag-link" href="#" onClick={() => this.finishUp(row.tag_id)}>{row.tag_desc}</a>
          </div>
        })
        }
      </div >
    )
  }
}

