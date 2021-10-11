//import './style.css';
//import Icon from './icon.png';
import * as ReactDOM from 'react-dom'
import * as React from 'react'
import Search from './app/Search'
import Playlist from './app/Playlist'

const e = React.createElement

const rootElem = <HTMLElement>document.getElementById('playlist_section')
const psCustomProps = rootElem.dataset.customProps // i pass an object in list.erb...
let playlistId: number | undefined
if (typeof psCustomProps !== 'undefined') {
  const props = JSON.parse(psCustomProps)
  playlistId = props['playlistId']
}
ReactDOM.render(
  e(Playlist, { playlistId: playlistId }),
  rootElem
)
ReactDOM.render(
  e(Search),
  document.getElementById('search_section')
)