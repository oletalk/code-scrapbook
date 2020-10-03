import React from 'react';
import axios from 'axios';

// props: name, id, axiosCall, callback, noSongsFound
class FetchButton extends React.Component {
  constructor(props) {
    super(props);

    this.performAxiosCall = this.performAxiosCall.bind(this);
  }

  performAxiosCall() {
    var selectedSongs = [];
    var a = this;

    axios.get(this.props.axiosCall)
    .then(function(response) {
      if (Array.isArray(response.data)) {
        selectedSongs = response.data;
      }
      if (selectedSongs.length > 0) {
        a.props.callback({
          data: selectedSongs
        });
      } else {
        let emptyResult = a.props.noSongsFound;
        if (typeof emptyResult === 'undefined') {
          emptyResult = 'No songs were found.'
        }
        alert(a.props.noSongsFound);
      }

    }
    )
    .catch(function(error) {
      console.log(error)
    })
  }

  render() {
    return (
      <input type='button' id={this.props.id} value={this.props.name}
      onClick={(e) => this.performAxiosCall() }
      />
    );


  }
}


export default FetchButton;
