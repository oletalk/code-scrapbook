import axios from 'axios'
import Playlist from './Playlist'
import { FC, useState, useEffect } from 'react'

interface PlaylistListProps {
    owner: string
}
interface PlaylistDesc {
    name: string,
    owner: string,
    date_created: string,
    date_modified: string
}

const PlaylistList: FC<PlaylistListProps> = (props: PlaylistListProps) => {
    
    const [plList, setPLList] = useState<Array<PlaylistDesc>>([])

    /* 'componentDidMount' */
    useEffect(() => {
        console.log('loading....')
        const url = 'http://192.168.0.2:1234' // use REACT_APP_OLD_BACKEND to check what old backend did

        console.log('we want playlists for ' + props.owner)
        axios.get(url + '/playlists')
        .then(response => setPLList(response.data))    
    }, [props.owner])

    return(
        <>
        {plList.map(pl => (
        <li>
          <Playlist
             name={pl.name}
             owner={pl.owner}
             date_created={pl.date_created}
             date_modified={pl.date_modified} />
        </li>
      ))}
        </>
    )

}

export default PlaylistList