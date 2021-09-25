import * as React from 'react'
import axios from 'axios'
import TooltipBox from './TooltipBox'
import LineItem from './LineItem'
import FetchButton from './FetchButton'
import { songFromJson, SongFromJson } from './js/playlist_util_t'

const MAX_LIST_LENGTH = 30

type RespData = {
  data: SongFromJson[]
}
type SearchState = {
  query: string
  songs: SongFromJson[]
  tooltipBox: TooltipBox | null
}
export default class Search extends React.Component<SearchState> {
  constructor(props: any) {
    super(props)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.addSongs = this.addSongs.bind(this)
  }
  state: SearchState = {
    query: '',
    songs: [],
    tooltipBox: null
  }

  setTooltip = (t: TooltipBox) => {
    this.setState({
      tooltipBox: t
    })
  }

  getTooltip = () => {
    return this.state.tooltipBox
  }

  // callback from the buttons
  addSongs = (s: RespData) => {
    let itemList = s.data
    itemList = itemList.slice(0, MAX_LIST_LENGTH)
    this.setState({
      query: '',
      songs: itemList
    })
  }

  handleInputChange(ev: React.FormEvent<HTMLInputElement>) {

    var a = this
    var str = ev.currentTarget.value
    a.setState({
      query: str
    })

    if (str.length > 3) {
      axios.get('/search/' + str)
        .then(function (response) { // process search results
          if (Array.isArray(response.data)) {

            let selectedSongs: SongFromJson[] = response.data
            console.log('Got ' + selectedSongs.length + ' song(s).')
            selectedSongs = selectedSongs.slice(0, MAX_LIST_LENGTH)
            a.setState({
              songs: selectedSongs
            })

          }
        })


    }
  }


  render() {
    return (
      <div>
        <span>
          <input id='criteria' type='text' placeholder='Search for song to add...'
            value={this.state.query}
            onChange={this.handleInputChange} />
          <FetchButton
            id='latestBtn' name='Latest' axiosCall='/query/latest'
            callback={this.addSongs} noSongsFound='No songs were added in the past month'
          />
          <FetchButton
            id='randomBtn' name='Random' axiosCall='/query/random/10'
            callback={this.addSongs}
          />
        </span>
        <ul className='click'>

          {this.state.songs.map((row, index) => {
            const item = songFromJson(index, row)
            return <LineItem outerSearch={this} key={item.counter} dataSource={item} />
          })}

        </ul>
        <TooltipBox outerSearch={this} />
      </div>
    )
  }
}

// export default Search;
