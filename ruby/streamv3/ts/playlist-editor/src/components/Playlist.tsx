import * as React from 'react'
import axios from 'axios'
import { FC, useState, useEffect, useRef } from 'react'

interface PlaylistProps {
  name: string,
  owner: string,
  date_created: Date,
  date_modified: Date,
  highlighted: boolean,
  allowEdit: boolean
}
interface SongDesc {
  title: string,
  url: string,
  secs: string
}
interface PlaylistState {
  songs: Array<SongDesc>,
  expanded: boolean,
  editing: boolean,
  dragSource: number | undefined,
  dragTarget: number | undefined
}
const Playlist: FC<PlaylistProps> = (props: PlaylistProps) => {
  const plsStart = useRef<HTMLDivElement>(null)

  const [playlist, setPlaylist] = useState<PlaylistState>({
    songs: [],
    expanded: false,
    editing: false,
    dragSource: undefined,
    dragTarget: undefined
  })

  function toggleExpanded() {
    const ex = playlist.expanded
    let ed = playlist.editing
    // if still editing, cancel it
    if (ex) {
      ed = false
    }

    setPlaylist(prevPlaylist => {
      return {
        ...prevPlaylist, /* js spread syntax. this includes everything else already in prevPlaylist */
        expanded: !ex,
        editing: ed
      }
    })
  }

  useEffect(() => {
    const url = process.env.REACT_APP_BACKEND
    axios.get(url + '/playlist/' + props.name)
      .then(response => {
        const plsongs: Array<SongDesc> = response.data
        setPlaylist({
          songs: plsongs,
          expanded: false,
          editing: false,
          dragSource: undefined,
          dragTarget: undefined
        })
      })

  }, [props.name])

  function handleDragStart(event: React.DragEvent, index: number) {
    setPlaylist(prevPlaylist => {
      return {
        ...prevPlaylist, /* js spread syntax. this includes everything else already in prevPlaylist */
        dragSource: index
      }
    })
  }

  function handleDragEnd(event: React.DragEvent) {
    const ds = playlist.dragSource
    const dt = playlist.dragTarget
    console.log('need to swap items ' + ds + '[drag source] <-> ' + dt + '[drag target]')
    let newSongs = playlist.songs
    if (typeof ds !== 'undefined' && typeof dt !== 'undefined') {
      const temp = newSongs[ds]
      newSongs[ds] = newSongs[dt]
      newSongs[dt] = temp
    }

    setPlaylist(prevPlaylist => {
      return {
        ...prevPlaylist, /* js spread syntax. this includes everything else already in prevPlaylist */
        songs: newSongs,
        dragSource: undefined,
        dragTarget: undefined
      }
    })
  }
  function handleDragEnter(event: React.DragEvent, index: number) {

    setPlaylist(prevPlaylist => {
      return {
        ...prevPlaylist, /* js spread syntax. this includes everything else already in prevPlaylist */
        dragTarget: index
      }
    })
  }

  function toggleEdit() {
    const ed = playlist.editing
    // if we're changing to editing and the list is collapsed, expand it
    let ex = playlist.expanded
    if (!ed) {
      ex = true
    }
    setPlaylist(prevPlaylist => {
      return {
        ...prevPlaylist, /* js spread syntax. this includes everything else already in prevPlaylist */
        editing: !ed,
        expanded: ex
      }
    })
  }

  return (
    <>
      <div ref={plsStart} className={props.highlighted ? 'playlist-highlighted' : 'playlist'}>
        <span className={playlist.expanded ? 'list-expanded' : 'list-collapsed'}
          onClick={toggleExpanded}>
          Playlist "{props.name}" (owner {props.owner}) {playlist.expanded ? '^' : 'V'}
        </span>
        {props.allowEdit ? <button onClick={toggleEdit}>{playlist.editing ? 'Cancel' : 'Edit'}</button> : ''}
        <ul className={playlist.expanded ? 'ul-expanded' : 'ul-collapsed'}>
          {playlist.songs.map((song, index) => (
            <li draggable
              onDragStart={(e) => handleDragStart(e, index)}
              onDragEnd={handleDragEnd}
              onDragEnter={(e) => handleDragEnter(e, index)} className={playlist.expanded ? 'playlist-item' : 'playlist-item-hidden'} key={index}>
              {song.title} {playlist.editing ? ' X ' : ''}
            </li>
          ))}
        </ul>
      </div>
    </>
  )


}



export default Playlist
