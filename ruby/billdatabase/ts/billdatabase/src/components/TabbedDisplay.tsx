import { useState } from "react"

interface TabbedContent {
  name: string,
  content: JSX.Element,
  nonEmpty?: boolean
}
interface TabProps {
  defaultTab?: string
  headerContent?: JSX.Element
  tabs: TabbedContent[]
}

interface TabbedDisplayState {
  selectedTab: string
}

/** Component to display tabbed content */
function TabbedDisplay(props: TabProps) {
  const defaultTab : string = (props.defaultTab !== undefined) ? props.defaultTab : props.tabs[0].name
  const [ displayState, setDisplayState ] = useState<TabbedDisplayState>({
    selectedTab: defaultTab
  })

  const switchTab = (str : string) => {
    setDisplayState({
      selectedTab: str
    })
  }

  const tabClass = (isSelected : boolean, hasContent : boolean) : string => {
    if (isSelected) {
      return 'senderTabSelected'
    } else {
      if (hasContent) {
        return 'senderTabContent'
      }
    }
    return 'senderTab'
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
              {props.tabs.map((aTab) => (
                            <span><button className={tabClass(displayState.selectedTab === aTab.name, aTab.nonEmpty === true)} 
                            onClick={() => switchTab(aTab.name)}>{aTab.name}</button>&nbsp;</span>
              ))}
            </td>
          </tr>    </table>
{props.tabs.map((aTab) => (
  <table className={aTab.name === displayState.selectedTab ? 'senderdetail' : 'senderdetail_hidden'}>
      <tr>
      <td colSpan={4}>
        {aTab.content}
      </td>
    </tr>
  </table>
))}

    </div>
  )
}

export default TabbedDisplay