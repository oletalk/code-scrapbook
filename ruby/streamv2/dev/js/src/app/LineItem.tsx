import * as React from 'react'
import SongLink from './SongLink'
import Search from './Search'
import { SongObject } from './js/playlist_util_t'

type LineItemProps = {
  dataSource: SongObject
  outerSearch: Search
}

export default class LineItem extends React.Component<LineItemProps> {
  constructor(props: any) {
    super(props)
    this.refreshHandler = this.refreshHandler.bind(this)
  }

  refreshHandler() {
    this.forceUpdate()
  }

  render() {
    const item = this.props.dataSource
    return (this.props.outerSearch.itemAlreadyInPlaylist(item.hash) ?
      (
        <li id={'s_' + item.hash}>{item.title}</li>
      )
      :
      (
        <li id={'s_' + item.hash} className={'title_' + item.derived}>
          <SongLink outerSearch={this.props.outerSearch} song={item} refreshHandler={this.refreshHandler} />
        </li>
      )
    )
  }
}

