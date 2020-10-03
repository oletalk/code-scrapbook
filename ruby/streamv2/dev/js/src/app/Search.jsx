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
    this.lineItems = this.lineItems.bind(this);

    // callbacks
    this.addSongs = this.addSongs.bind(this);
  }

  lineItems (arr) {
    var si = 0;

    return arr.slice(0, MAX_LIST_LENGTH).map(
      (row) => {
        let item = songFromJson(++si, row);
        return <LineItem outerSearch={this} key={item.counter} dataSource={item} />
      }
    )
  }

  // callback from the buttons
  // you need to apply lineItems to s.data
  addSongs(s) {
    this.setState({
      query: '',
      songs: this.lineItems(s.data)
    });
  }

  handleInputChange (ev) {

    var a = this;
    var selectedSongs = [];
    var str = ev.target.value;

    if (str.length > 3) {
      axios.get('/search/' + str)
      .then(function (response) { // process search results
        if (Array.isArray(response.data)) {

          selectedSongs = a.lineItems(response.data);

          console.log('Got ' + selectedSongs.length + ' song(s).');
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
          {this.state.songs}
        </ul>
        <TooltipBox outerSearch={this} />
      </div>
    );
  }
}

export default Search;
