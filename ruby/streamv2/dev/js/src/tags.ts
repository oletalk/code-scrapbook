//import './style.css';
//import Icon from './icon.png';
import * as ReactDOM from 'react-dom'
import * as React from 'react'
import DescTagList from './app/tags/DescTagList'

const e = React.createElement

const rootElem = <HTMLElement>document.getElementById('tageditor_section')
const psCustomProps = rootElem.dataset.customProps // i pass an object in list.erb...
let songHash: number | undefined
if (typeof psCustomProps !== 'undefined') {
  const props = JSON.parse(psCustomProps)
  songHash = props['songHash']
}
const taglist = e(DescTagList, { hash: songHash })

ReactDOM.render(
  taglist,
  rootElem
)