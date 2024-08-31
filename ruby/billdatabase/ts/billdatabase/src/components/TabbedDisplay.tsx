import { useState } from "react"

interface TabProps {
  tabNames: string[]
  defaultTab?: number
  headerContent?: JSX.Element
  content: JSX.Element[]
}

interface TabbedDisplayState {
  selectedTab: number
}

function TabbedDisplay(props: TabProps) {
  const numTabs = props.tabNames.length
  const defaultTab : number = (props.defaultTab !== undefined) ? props.defaultTab : 1
  const [ displayState, setDisplayState ] = useState<TabbedDisplayState>({
    selectedTab: defaultTab
  })



  if (defaultTab > numTabs) {
    return (<div>defaultTab provided is greater than the number of tabs!</div>)
  }
  if (props.content.length !== numTabs) {
    return (<div>Number of content snippets isn't equal to the number of tab names!</div>)
  }

  const switchTab = (num : number) => {
    setDisplayState({
      selectedTab: num
    })
  }

  return (
    <div>
    <table className="tabs">
      {props.headerContent === undefined 
      ? (<tr>
        <td colSpan={4}>&nbsp;</td>
      </tr>)
      : (<tr>
        <td colSpan={4}>
          {props.headerContent}
        </td>
      </tr>)}
      <tr>
            <td colSpan={4} className='tabContainer' >
              {props.tabNames.map((tabName, index) => (
                            <span><button className={displayState.selectedTab === index+1 ? 'senderTabSelected' : 'senderTab' } 
                            onClick={() => switchTab(index+1)}>{tabName}</button>&nbsp;</span>
              ))}
            </td>
          </tr>    </table>
{props.content.map((element, index) => (
  <table className={index+1 === displayState.selectedTab ? 'senderdetail' : 'senderdetail_hidden'}>
      <tr>
      <td colSpan={4}>
        {element}
      </td>
    </tr>
  </table>
))}

    </div>
  )
}

export default TabbedDisplay