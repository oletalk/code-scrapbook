import * as React from 'react'
import axios from 'axios'

// props: name, id, axiosCall, callback, noSongsFound
type SelectedSongs = {
  data: any[]
}

type FetchButtonProps = {
  axiosCall: string
  id: string
  name: string
  // eslint-disable-next-line no-unused-vars
  callback: (s: SelectedSongs) => void
  noSongsFound?: string
}

export default class FetchButton extends React.Component<FetchButtonProps> {
  constructor(props: any) {
    super(props)

    this.performAxiosCall = this.performAxiosCall.bind(this)
  }

  performAxiosCall() {
    let selectedSongs: any[] = []
    const a = this

    axios.get(this.props.axiosCall)
      .then(function (response) {
        if (Array.isArray(response.data)) {
          selectedSongs = response.data
        }
        if (selectedSongs.length > 0) {
          a.props.callback({
            data: selectedSongs
          })
        } else {
          let emptyResult = a.props.noSongsFound
          if (typeof emptyResult === 'undefined') {
            emptyResult = 'No songs were found.'
          }
          alert(a.props.noSongsFound)
        }

      }
      )
      .catch(function (error) {
        console.log(error)
      })
  }

  render() {
    return (
      <input type='button' id={this.props.id} value={this.props.name}
        onClick={() => this.performAxiosCall()}
      />
    )


  }
}

