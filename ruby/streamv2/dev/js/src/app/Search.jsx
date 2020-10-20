import React from 'react';
import axios from 'axios';
import TooltipBox from './TooltipBox.jsx';
import LineItem from './LineItem.jsx';
import FetchButton from './FetchButton.jsx';


const MAX_LIST_LENGTH = 30;

class Search extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      query: '',
      songs: []
    };

    this.handleInputChange = this.handleInputChange.bind(this);
    // callbacks
    this.addSongs = this.addSongs.bind(this);
  }

  // callback from the buttons
  addSongs(s) {
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

    if (str.length > 3) {
      axios.get('/search/' + str)
      .then(function (response) { // process search results
        if (Array.isArray(response.data)) {

          let selectedSongs = response.data;
          console.log('Got ' + selectedSongs.length + ' song(s).');
          selectedSongs = selectedSongs.slice(0, MAX_LIST_LENGTH);
          a.setState({
            query: '',
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
          value={this.state.query.value}
          onChange={(e) => this.handleInputChange(e) } />
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

export default Search;
