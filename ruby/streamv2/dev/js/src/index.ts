//import './style.css';
//import Icon from './icon.png';
import * as ReactDOM from 'react-dom'
import * as React from 'react'
import Container from './app/Container'

const e = React.createElement

const rootElem = <HTMLElement>document.getElementById('playlist_section')
const psCustomProps = rootElem.dataset.customProps // i pass an object in list.erb...
let playlistId: number | undefined
if (typeof psCustomProps !== 'undefined') {
  const props = JSON.parse(psCustomProps)
  playlistId = props['playlistId']
}
const container = e(Container, { playlistId: playlistId })

ReactDOM.render(
  container,
  rootElem
)