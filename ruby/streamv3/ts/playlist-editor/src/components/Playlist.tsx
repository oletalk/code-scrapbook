import axios from 'axios'
import { FC, useState, useEffect } from 'react'

interface PlaylistProps {
  name: string,
  owner: string,
  date_created: string,
  date_modified: string
}
interface SongDesc {
  title: string,
  url: string,
  secs: string
}
const Playlist: FC<PlaylistProps> = (props: PlaylistProps) => {
  const [playlist, setPlaylist] = useState<Array<SongDesc>>([])

  useEffect(() => {
    const url = 'http://192.168.0.2:1234' // use REACT_APP_OLD_BACKEND to check what old backend did
    axios.get(url + '/playlist/' + props.name)
      .then(response => setPlaylist(response.data))
  
}, [props.name])
  return (
    <>
      <div className="playlist">Playlist "{props.name}" (owner {props.owner})</div>
    </>
  )


}



export default Playlist