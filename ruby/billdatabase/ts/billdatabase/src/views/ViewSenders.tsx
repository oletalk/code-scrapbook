import { SenderInfo, NavType } from '../common/types-class'
import React from "react";
import { Link } from 'react-router-dom';
import * as Constants from '../common/constants'
import Nav from '../components/Nav'

type SenderProps = {

}
type senderbox = {
  info: SenderInfo,
  expanded: boolean,
  changed: boolean
}
type SenderState = {
  senders:  senderbox[]
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
    this.toggleExpand = this.toggleExpand.bind(this)
  }

  state: SenderState = {
    senders: []
  }

  getSenderBox = (id: string) : senderbox | undefined => {
    return this.state.senders.find(s => s.info.id === id)
  }

  saveSenderBox = (senderId: string, sb: senderbox) => {
    const newState = [...this.state.senders]

    newState.map(sbox => {
      if (sbox.info.id === senderId) {
        sbox.changed = (sbox.info !== sb.info) // TODO: does it do a deep compare??
        sbox.info = sb.info
        return sbox
      } else {
        return sbox
      }
    })

    this.setState({
       senders: newState
    })    

  }

  toggleExpand = (id: string) => {
    let sbox = this.getSenderBox(id)
    if (sbox !== undefined) {
      sbox.expanded = !sbox.expanded
      this.saveSenderBox(id, sbox)
    } else {
      console.error('sender box id #' + id + ' not found!')
    }
  }

  fetchSenders = () => {
    console.log('fetching sender data.')
    fetch(Constants.BACKEND_URL + '/senders')
    .then((response) => {
    // Check if the request was successful
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
        return response.json()
      })
      .then((json) => {
        let allSenders = json as SenderInfo[]
        let sendermap : senderbox[] = allSenders.map(
          s => {
            return {
              info: s,
              expanded: false,
              changed: false
            }
          }
        )
        this.setState({
          senders: sendermap
        })
      })
  }

  render() {
    return (
      <div className="App">
              <Nav page={NavType.Senders} />
        <h2>Sender List</h2>
        <table className="senderlist">
          <tbody>
          {this.state.senders.map(sbox => {
               return <tr key={sbox.info.id}>
                  <td>
                  <div>
                      <input type='button' onClick={() => this.toggleExpand(sbox.info.id)} value=" + " />
                     <Link to={"/sender/" + sbox.info.id }>{sbox.info.name}</Link>

                    </div>
                    <div className={sbox.expanded ? 'sender-expanded' : 'sender-collapsed'} >
                      <div>
                      <label>Username</label><span className='optional'> (optional): </span>
                      { sbox.info.username !== '' ? sbox.info.username : 'N/A' }
                      </div>
                      <div className="tooltip">
                      <label>Password hint:</label>
                      <span className='tooltiptext'>{ sbox.info.password_hint }</span>
                      </div>
                    </div>
                  </td>
              </tr>
        })}
                  </tbody>
        </table>
    </div>
    )
  }
}