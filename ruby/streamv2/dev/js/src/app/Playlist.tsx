import * as React from 'react'
import axios from 'axios'
import Container from './Container'
import { songFromJson, SongFromJson } from './js/playlist_util_t'

// TODO - complete pre-submit checks (check name and list not empty)
//      - check new playlist saves successfully
//      - bug: newly added item has no secs_display value
type PlaylistProps = {
  playlistId: number | undefined,
  container: Container
}
type PlaylistState = {
  pid: number | undefined
  pname: string,
  songs: SongFromJson[],
  selectedSongs: string[],
  changed: boolean,
  btnDisabled: { up: boolean, down: boolean }
}
export default class Playlist extends React.Component<PlaylistProps, PlaylistState> {
  constructor(props: any) {
    super(props)

    this.toggleMoveButtons = this.toggleMoveButtons.bind(this)
    this.findSongInList = this.findSongInList.bind(this)
    this.fetchPlaylist = this.fetchPlaylist.bind(this)
    this.moveUp = this.moveUp.bind(this)
    this.moveDown = this.moveDown.bind(this)
    this.moveItem = this.moveItem.bind(this)
    this.checkBeforeLeaving = this.checkBeforeLeaving.bind(this)
    this.setPname = this.setPname.bind(this)
    this.deleteSongs = this.deleteSongs.bind(this)
    this.savePlaylist = this.savePlaylist.bind(this)
    this.checkPlaylist = this.checkPlaylist.bind(this)
    this.hasItem = this.hasItem.bind(this)
    this.addItem = this.addItem.bind(this)

    this.props.container.setState({ innerPlaylist: this })
  }
  state: PlaylistState = {
    pid: undefined,
    pname: '',
    songs: [],
    selectedSongs: [],
    changed: false,
    btnDisabled: { up: true, down: true }
  }

  addItem(s: SongFromJson) {
    // check.
    if (this.hasItem(s.hash)) {
      console.log('ERROR! This playlist already has this item')
    } else {
      const songList = [...this.state.songs]
      songList.push(s)
      this.setState({
        songs: songList,
        changed: true
      })
    }
  }
  hasItem(s: string) {
    let ret = false
    for (const song of this.state.songs) {
      if (song.hash === s) {
        ret = true
        break
      }
    }
    return ret
  }
  setPname(e: any) {
    const t: HTMLInputElement = e.target
    this.setState({ pname: t.value, changed: true })
  }
  checkBeforeLeaving(e: React.MouseEvent): void {
    if (this.state.changed) {
      if (!confirm('You have unsaved changes. Really leave this page?')) {
        e.preventDefault()
      }
    }
  }
  editTag(hash: string): void {
    window.location.href = '/tag/' + hash + '/' + this.props.playlistId
  }
  componentDidMount() {
    if (typeof this.props.playlistId !== 'undefined') {
      this.setState({ pid: this.props.playlistId })
      this.fetchPlaylist()
    } else {
      console.log('no playlist id provided - new playlist')
    }
  }

  toggleMoveButtons(e: any) {
    const t: HTMLSelectElement = e.target
    const sel: string[] = []
    let disableUp = false
    let disableDown = false

    // console.log('number of selected options = ' + t.selectedOptions.length)
    const items = this.state.songs
    let firstItem
    let lastItem
    if (items.length > 0) {
      firstItem = items[0].hash
      lastItem = items[items.length - 1].hash
    }

    for (let i = 0; i < t.selectedOptions.length; i++) {
      const opt = t.selectedOptions[i]
      sel.push(opt.value)

      // if 1st item is selected disable up button
      if (opt.value === firstItem) {
        disableUp = true
      }
      // if last item is selected disable down button
      if (opt.value === lastItem) {
        disableDown = true
      }

    }
    // can't move more than one option
    if (t.selectedOptions.length !== 1) {
      disableUp = true
      disableDown = true
    }
    this.setState({
      selectedSongs: sel,
      btnDisabled: { up: disableUp, down: disableDown }
    })
  }
  findSongInList(hash: string) {
    let item = -1
    let ctr = -1
    for (const song of this.state.songs) {
      ctr++
      if (song.hash === hash) {
        item = ctr
        break
      }
    }
    return item
  }
  moveItem(direction: number, songPos: number) {
    const songs = [...this.state.songs]
    const temp = songs[songPos]
    songs[songPos] = songs[songPos + Math.sign(direction)]
    songs[songPos + Math.sign(direction)] = temp
    // and disable up button if at top of list
    let down = this.state.btnDisabled.down
    let up: boolean = this.state.btnDisabled.up
    if (songPos <= 1 && direction < 0) {
      up = true
    } else {
      up = false
    }
    if (songPos >= this.state.songs.length - 2 && direction > 0) {
      down = true
    } else {
      down = false
    }
    this.setState({
      songs: songs,
      changed: true,
      btnDisabled: {
        down: down,
        up: up
      }
    })

  }
  moveUp() {
    if (!this.state.btnDisabled.up) {
      // 1 song should be selected, otherwise button would be disabled
      const songPos = this.findSongInList(this.state.selectedSongs[0])
      console.log('moving up song #' + songPos + ' ...')
      this.moveItem(-1, songPos)
    }
  }
  moveDown() {
    if (!this.state.btnDisabled.down) {
      // 1 song should be selected, otherwise button would be disabled
      const songPos = this.findSongInList(this.state.selectedSongs[0])
      console.log('moving down song #' + songPos + ' ...')
      this.moveItem(1, songPos)
    }
  }

  checkPlaylist() {
    const errors: string[] = []
    if (this.state.pname == '') {
      errors.push('Please provide a name for the playlist')
    }
    if (this.state.songs.length < 2) {
      errors.push('Please add at least 2 songs to the playlist')
    }
    if (errors.length === 0) {
      this.savePlaylist()
    } else {
      alert(errors.join("\n"))
    }
  }
  savePlaylist() {
    const songids = this.state.songs.map((x) => x.hash)
    const data = {
      pid: this.props.playlistId,
      pname: this.state.pname,
      songids: songids.join(',')
    }
    console.log(data)
    axios.post('/playlist/save', data)
      .then((response) => {
        console.log(response)
        this.setState({ changed: false })
        alert('Your playlist was successfully saved!')
      }
      )
      .catch((error) => {
        console.log(error)
      })
  }

  deleteSongs() {
    if (this.state.selectedSongs.length > 0) {
      const remainingSongs: SongFromJson[] = []
      for (const i of this.state.songs) {
        if (this.state.selectedSongs.indexOf(i.hash) === -1) {
          remainingSongs.push(i)
        }
      }
      // TODO: update the SongLink(s) with the hash(es) of the deleted song(s)
      this.setState({ changed: true, songs: remainingSongs })
      this.props.container.state.innerSearch.forceUpdate()
    } else {
      alert('Please select at least one song to delete.')
    }
  }

  fetchPlaylist() {
    let selectedSongs: any[] = []
    const a = this

    axios.get('/playlist/json/' + this.props.playlistId)
      .then(function (response) {
        let playlistName = ''
        if (Array.isArray(response.data)) {
          if (typeof response.data[0].name !== 'undefined') {
            playlistName = response.data[0].name
          }
          selectedSongs = response.data
        }
        a.setState({
          songs: selectedSongs,
          pname: playlistName
        })
      }
      )
      .catch(function (error) {
        console.log(error)
      })
  }


  render() {
    return (
      <div>
        <div className='layout'>
          <label htmlFor="playlist_name">Playlist name: </label>
          <input id="playlist_name" onChange={this.setPname} type="text" name="pname" placeholder="Playlist name..." value={this.state.pname} />
          | <a title="close" onClick={this.checkBeforeLeaving} href="/playlist/manage">x</a>
        </div>
        <table className='layout'>
          <tbody>
            <tr>
              <td>
                <select
                  onChange={this.toggleMoveButtons}
                  value={this.state.selectedSongs}
                  size={8} id="playlist"
                  name="playlist" multiple >
                  {this.state.songs.map((row, index) => {
                    const item = songFromJson(index, row)
                    return <option
                      onDoubleClick={() => this.editTag(item.hash)}
                      key={item.hash} value={item.hash}
                      id={item.hash} >{item.title} [ {item.secs_display} ]</option>
                  })}
                </select>
              </td>
              <td valign='bottom'>
                <a onClick={this.moveUp}><img title="up" alt="up" src="/img/up-and-down.png" id="move-up" className={(this.state.btnDisabled.up ? 'disabled ' : '') + ' up'} /></a><br />
                <a onClick={this.moveDown}><img title="down" alt="down" src="/img/up-and-down.png" id="move-down" className={(this.state.btnDisabled.down ? 'disabled ' : '') + ' down'} /></a><br />
              </td>
            </tr>
          </tbody>
        </table>
        <span>
          <input type='button' value='Delete' onClick={this.deleteSongs} /> &nbsp;
          <input type='button' value='Save' onClick={this.checkPlaylist} />
        </span>
      </div>
    )
  }
}

// export default Playlist;
