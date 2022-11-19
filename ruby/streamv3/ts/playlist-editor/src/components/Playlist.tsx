import * as React from 'react'
import axios from 'axios'

type PlaylistProps = {
  name: string,
}
type PlaylistState = {
  songs: Song[],
  expanded: boolean
}
type Song = { /* TODO: put into library file */
  secs: number,
  title: string,
  url: string
}

export default class Playlist extends React.Component<PlaylistProps, PlaylistState> {
  constructor(props: any) {
    super(props)
    this.loadPlaylist = this.loadPlaylist.bind(this)
    this.toggleList = this.toggleList.bind(this)
  }
  state: PlaylistState = {
    songs: [],
    expanded: false
  }
  loadPlaylist = () => {
    let a = this
    const url = 'http://192.168.0.2:1234' // use REACT_APP_OLD_BACKEND to check what old backend did
    axios.get(url + '/playlist/' + this.props.name)
      .then(response => a.setState({
        songs: response.data
      }))

  }
  toggleList = () => {
    this.setState({
      expanded: !(this.state.expanded)
    })
  }
  componentDidMount(): void {
    this.loadPlaylist()
  }
  render() {
    return (
      <div>
        <div onClick={this.toggleList} className='playlist-header'>Playlist: {this.props.name}</div>
        {this.state.songs.map((row: Song, index: number) => {
          return <div
            className={this.state.expanded ? 'playlist-item' : 'playlist-item-hidden'}
            key={index}>{row.title}</div>
        })}
      </div>
    )
  }
}