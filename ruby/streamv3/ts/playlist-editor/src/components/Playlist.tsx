import * as React from 'react'
import axios from 'axios'
import { FC, useState, useEffect } from 'react'

interface PlaylistProps {
  name: string,
  owner: string,
  date_created: Date,
  date_modified: Date
}
interface SongDesc {
  title: string,
  url: string,
  secs: string
}
interface PlaylistState {
  songs: Array<SongDesc>,
  expanded: boolean
}
const Playlist: FC<PlaylistProps> = (props: PlaylistProps) => {
  const [playlist, setPlaylist] = useState<PlaylistState>({
    songs: [],
    expanded: false
  })

  function toggleExpanded() {
    const ex = playlist.expanded
    setPlaylist(prevPlaylist => {
      return {
        ...prevPlaylist, /* js spread syntax. this includes everything else already in prevPlaylist */
        expanded: !ex
      }
    })
  }

  useEffect(() => {
    const url = 'http://192.168.0.2:1234' // use REACT_APP_OLD_BACKEND to check what old backend did
    axios.get(url + '/playlist/' + props.name)
      .then(response => {
        const plsongs: Array<SongDesc> = response.data
        setPlaylist({
          songs: plsongs,
          expanded: false
        })
      })

  }, [props.name])
  return (
    <>
      <div className="playlist">
        <span className={playlist.expanded ? 'list-expanded' : 'list-collapsed'}
          onClick={toggleExpanded}>Playlist "{props.name}" (owner {props.owner}) {playlist.expanded ? '^' : 'V'}</span>
        <ul className={playlist.expanded ? 'ul-expanded' : 'ul-collapsed'}>
          {playlist.songs.map((song, index) => (
            <li className={playlist.expanded ? 'playlist-item' : 'playlist-item-hidden'} key={index}>{song.title}</li>
          ))}
        </ul>
      </div>
    </>
  )


}



export default Playlist
