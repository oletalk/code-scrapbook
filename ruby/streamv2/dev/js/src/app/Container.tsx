import * as React from 'react'
import Playlist from './Playlist'
import Search from './Search'
import { SongFromJson } from './js/playlist_util_t'

type ContainerProps = {
  playlistId: number,
}
type ContainerState = {
  innerPlaylist: Playlist,
  innerSearch: Search
}
export default class Container extends React.Component<ContainerProps, ContainerState> {
  constructor(props: any) {
    super(props)
    this.playlistHasItem = this.playlistHasItem.bind(this)
    this.addToPlaylist = this.addToPlaylist.bind(this)
  }

  addToPlaylist(s: SongFromJson): void {
    this.state.innerPlaylist.addItem(s)
  }

  playlistHasItem(h: string): boolean {
    // TODO - test if this works!
    return this.state.innerPlaylist.hasItem(h)
  }

  render() {
    return (
      <div>
        <Playlist container={this} playlistId={this.props.playlistId} />
        <Search container={this} />
      </div>
    )
  }
}

