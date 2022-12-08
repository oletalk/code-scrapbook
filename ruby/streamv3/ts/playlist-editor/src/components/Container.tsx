import * as React from 'react'
import { FC, useState } from 'react'
import PlaylistList from './PlaylistList'
import SearchBox from './SearchBox'

/** 
 * Overall container
 */
// interface ContainerProps {
//   name: string
// }
interface ContainerState {
  highlightList: Array<string>
}
const Container: FC = () => {
  const [container, setContainer] = useState<ContainerState>({
    highlightList: []
  })
  function onResult(stuff: Array<string>) {
    console.log('onResult called with stuff = ' + stuff)
    setContainer({
      highlightList: stuff
    })
  }
  return (
    <div>
      <SearchBox name="box" resultCallback={onResult} />
      <PlaylistList owner='me' highlights={container.highlightList} />
    </div>
  )
}

export default Container