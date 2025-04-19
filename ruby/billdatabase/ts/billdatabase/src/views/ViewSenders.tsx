import { SenderInfo, NavType, TagObject, senderbox } from '../common/types-class'
import { doFetch } from '../common/fetch'
import React from "react"
import SenderInfoRow from '../components/SenderInfoRow'
import * as Constants from '../common/constants'
import FilterByTag from '../components/TagFilter'
import Nav from '../components/Nav'

type SenderProps = {

}
type SenderState = {
  senders:  senderbox[],
  tags: TagObject[]
}

/*
  TODO: 1. get basic css
        2. fill out expanded section
*/
export default class ViewSenders extends React.Component<SenderProps, SenderState> {
  constructor(props: any) {
    super(props)

    // this.fetchTags = this.fetchTags.bind(this)
    this.fetchSenders()
    this.getTagList()
  }

  state: SenderState = {
    senders: [],
    tags: []
  }

  getTagList = () => {
    console.log('fetching all tags.')
    doFetch<TagObject[]>(Constants.BACKEND_URL + '/tags')
    .then((json) => {
      this.setState({
        tags: json
      })
      })

  }


  fetchSenders = () => {
    console.log('fetching sender data.')
    doFetch<SenderInfo[]>(Constants.BACKEND_URL + '/json/sendertags')
    .then((json) => {
        // let allSenders : SenderInfo[] = json
        let sendermap : senderbox[] = json.map(
          s => {
            return {
              info: s,
              expanded: false,
              filtered: false
            }
          }
        )
        this.setState({
          senders: sendermap
        })
      })
  }

  intersects = (x: string[], y: string[]) => {
    console.log(x)
    console.log(y)
    console.log('--------')
    return x.filter(val => y.includes(val)).length > 0
  }

  // TODO this doesn't work 
  //      because the screen doesn't have each sender's actual tags
  doTagFilter = (x: string[]) => {
    console.log('need to filter on ' + x)
    let senderList = this.state.senders
    let filtering = (x.length > 0)

    for (let sender of senderList) {
      // sender's tags
      const sendertags = sender.info.sender_tags.map(t => t.id)
      // do the sender's tags coincide with the tags in x?
      if (filtering) {
        sender.filtered = !this.intersects(x, sendertags)
        console.log('filtering sender id ' + sender.info.id + '? ' + sender.filtered)
      } else {
        sender.filtered = false
      }
    }
    this.setState({
      senders: senderList
    })
  }

  render() {
    return (
      <div className="App">
              <Nav page={NavType.Senders} />
        <h2>Sender List</h2>
        <div className='advice'>Expand each sender to view documents added under each sender. You can add notes for a sender in the maintenance screen for the sender.</div>

        <FilterByTag 
            tags={this.state.tags} 
            filterCallbackOn={(x : any) => this.doTagFilter(x)}
            />
        <table className="senderlist">
          <tbody>
          {this.state.senders.sort((a,b) => { return ('' + a.info.name).localeCompare(b.info.name) }).map(sbox => {
               return <SenderInfoRow 
                    info={sbox.info}
                    expanded={sbox.expanded}
                    filtered={sbox.filtered} />
        })}
                  </tbody>
        </table>
    </div>
    )
  }
}