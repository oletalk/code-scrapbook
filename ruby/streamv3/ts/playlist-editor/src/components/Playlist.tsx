import axios from 'axios'
import { FC, useState } from 'react'

interface PlaylistProps {
  id: number
}

const Playlist: FC<PlaylistProps> = ({ id }) => {
  const [playlist, setPlaylist] = useState({})


  const url = '' // use REACT_APP_OLD_BACKEND to check what old backend did
  axios.get(url + '/playlists' + id)
    .then(response => setPlaylist(response.data))


  return (
    <>
      <div className="playlist">Playlist id {id}</div>
    </>
  )


}



export default Playlist