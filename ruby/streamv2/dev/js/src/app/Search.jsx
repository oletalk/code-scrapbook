import React from 'react';
import axios from 'axios';
import TooltipBox from './TooltipBox.jsx';
import LineItem from './LineItem.jsx';


const MAX_LIST_LENGTH = 30;

class Search extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      query: '',
      songs: []
    };

    this.handleInputChange = this.handleInputChange.bind(this);
    this.addRandomSongs = this.addRandomSongs.bind(this);
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

  addRandomSongs (num) {
    var a = this;
    var selectedSongs = [];

    axios.get('/random/' + num)
    .then(function(response) {
      if (Array.isArray(response.data)) {
        selectedSongs = a.lineItems(response.data);
      }

      a.setState({
        query: '',
        songs: selectedSongs
      });
    })
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
          <input type='button' id='randomBtn' value='Random'
          onClick={(e) => this.addRandomSongs(10) }
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
