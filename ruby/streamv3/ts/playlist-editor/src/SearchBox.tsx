import * as React from 'react'
import axios from 'axios'

/** Component to allow searching for a tune in the global playlist
 * TODO
 * 
 * It should show tune details, last played, number of times played
 * and the playlists it is in
 */
type SearchBoxProps = {
  name: string,
}
type SearchBoxState = {
  search: string
}
export default class Playlist extends React.Component<SearchBoxProps, SearchBoxState> {
  constructor(props: any) {
    super(props)
    this.searchForPlaylists = this.searchForPlaylists.bind(this)
  }
  state: SearchBoxState = {
    search: ''
  }

  searchForPlaylists = () => {
    console.log('searching for playlists with search string ' + this.state.search)
  }

  render() {
    return <div>hello world i am searchbox</div>
  }
}