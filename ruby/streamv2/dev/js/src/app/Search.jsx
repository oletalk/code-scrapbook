import React from 'react';
import TooltipBox from './TooltipBox.jsx';

class Search extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      query: '',
      songs: []
    };
  }
  render() {
    return (
      <div>
        <span>
          <input type='text' placeholder='Search for song to add...'
          value={this.state.query.value} />
          <input type='button' id='randomBtn' value='Random'
          />
        </span>
        <ul className='click'>
          {this.state.songs}
        </ul>
        <TooltipBox />
      </div>
    );
  }
}

export default Search;
