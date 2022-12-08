import * as React from 'react'
import axios from 'axios'
import { FC, useState } from 'react'

/** Component to allow searching for a tune in the global playlist
 * TODO
 * 
 * It should show tune details, last played, number of times played
 * and the playlists it is in
 */
interface SearchBoxProps {
  name: string,
  resultCallback: (s: Array<string>) => void
}
interface PlaylistProps {
  name: string,
  owner: string,
  date_created: Date,
  date_modified: Date
}
interface SearchBoxState {
  search: string,
  results: Array<PlaylistProps>
}
const SearchBox: FC<SearchBoxProps> = (props: SearchBoxProps) => {
  const [searchbox, setSearchBox] = useState<SearchBoxState>({
    search: '',
    results: []
  })
  function checkSearch(event: React.ChangeEvent<HTMLInputElement>) {
    setSearchBox(prevSB => {
      return {
        ...prevSB,
        search: event.target.value
      }
    })
  }
  function searchForPlaylists() {
    if (searchbox.search.length >= 3) {
      console.log('searching for playlists with search string ' + searchbox.search)
      const url = 'http://192.168.0.2:1234' // use REACT_APP_OLD_BACKEND to check what old backend did
      axios.get(url + '/search/' + searchbox.search)
        .then(response => {
          const plsongs: Array<PlaylistProps> = response.data
          setSearchBox(prevSB => {
            return {
              ...prevSB,
              results: plsongs
            }

          })
          /* seems we can't use searchbox.results yet, 
             and maybe we shouldn't, so just use the 
             parsed output from response.data instead */
          const plNames = plsongs.map(pl => pl.name)
          props.resultCallback(plNames)
        })
    } else {
      alert('Please enter a search term of 3 characters or longer.')
    }
  }

  return (
    <div>Search:
      <input type="text" name="search" value={searchbox.search} onChange={checkSearch} />
      <input type="button" value="Search" onClick={searchForPlaylists} />
    </div>
  )
}

export default SearchBox