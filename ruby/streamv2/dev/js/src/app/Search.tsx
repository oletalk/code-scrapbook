import * as React from 'react';
import axios from 'axios';
import TooltipBox from './TooltipBox';
import LineItem from './LineItem';
import FetchButton from './FetchButton';
import { songFromJson } from './js/playlist_util.js'

const MAX_LIST_LENGTH = 30;

type SearchState = {
  query: string
  songs: string[]
  tooltipBox: TooltipBox
}
export default class Search extends React.Component<SearchState> {
  constructor(props) {
    super(props)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.addSongs = this.addSongs.bind(this)
  }
  state = {
    query: '',
    songs: [],
    tooltipBox: null
  }    

  // no need for .bind(this) now??
  // this.handleInputChange = this.handleInputChange.bind(this);
    // callbacks
    // this.addSongs = this.addSongs.bind(this);
  
  // new asof 18/9/21
  setTooltip = (t: TooltipBox) => {
    this.setState({
      tooltipBox: t
    })
  }

  getTooltip = () => {
    return this.state.tooltipBox
  }

  // callback from the buttons
  addSongs = (s) => {
    let itemList = s.data;
    itemList = itemList.slice(0,MAX_LIST_LENGTH);
    this.setState({
      query: '',
      songs: itemList
    });
  }

  handleInputChange (ev) {

    var a = this;
    var str = ev.target.value;
    console.log('ev value = ' + str)
    a.setState({
      query: str
    })

    if (str.length > 3) {
      axios.get('/search/' + str)
      .then(function (response) { // process search results
        if (Array.isArray(response.data)) {

          let selectedSongs = response.data;
          console.log('Got ' + selectedSongs.length + ' song(s).');
          selectedSongs = selectedSongs.slice(0, MAX_LIST_LENGTH);
          a.setState({
            songs: selectedSongs
          });

        } // if ...
      });


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
            let item = songFromJson(index, row);
            return <LineItem outerSearch={this} key={item.counter} dataSource={item} />
          })}

        </ul>
        <TooltipBox outerSearch={this} />
      </div>
    );
  }
}

// export default Search;
