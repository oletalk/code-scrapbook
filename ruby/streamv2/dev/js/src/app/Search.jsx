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
  }

  handleInputChange (ev) {

    var a = this;
    var selectedSongs = [];
    var str = ev.target.value;

    if (str.length > 3) {
      axios.get('/search/' + str)
      .then(function (response) { // process search results
        if (Array.isArray(response.data)) {

          for (let si = 0; si < response.data.length; si++) {
            let item = songFromJson(si, response.data[si]);
            if (selectedSongs.length <= MAX_LIST_LENGTH) {
              selectedSongs.push(
                <LineItem outerSearch={a} key={item.counter} dataSource={item} />
              )

          }
        } // for...

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
    // TODO: need to link the TooltipBox to (generated) LineItems somehow
    return (
      <div>
        <span>
          <input type='text' placeholder='Search for song to add...'
          value={this.state.query.value}
          onChange={(e) => this.handleInputChange(e) } />
          <input type='button' id='randomBtn' value='Random'
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
