import * as React from 'react'
import Playlist from './Playlist'
import Search from './Search'

type ContainerProps = {
  playlistId: number,
}
type ContainerState = {
  innerPlaylist: Playlist,
  innerSearch: Search
}
// this class is just here to allow passing of instructions
// between the Playlist and the Search's components :-]
export default class Container extends React.Component<ContainerProps, ContainerState> {
  constructor(props: any) {
    super(props)
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

