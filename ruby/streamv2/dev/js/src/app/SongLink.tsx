import * as React from 'react'
// import * as PropTypes from 'prop-types';
import Search from './Search'
import { SongObject, SongFromJson, SongObjectToJson } from './js/playlist_util_t'
// import TooltipBox from './TooltipBox'

type SongLinkProps = {
  outerSearch: Search
  song: SongObject
  refreshHandler: () => void
}

export default class SongLink extends React.Component<SongLinkProps> {
  constructor(props: any) {
    super(props)
    if (this.props.outerSearch == null) {
      console.warn('outerSearch is null! no link back to outer Search component.')
    }
    this.mouseOverFunc = this.mouseOverFunc.bind(this)
    this.onClickFunc = this.onClickFunc.bind(this)
    this.tooltipHide = this.tooltipHide.bind(this)
    this.tooltipMove = this.tooltipMove.bind(this)
    this.tooltipShow = this.tooltipShow.bind(this)
    //this.getTooltip  = this.getTooltip.bind(this)
  }

  getTooltip() {
    return this.props.outerSearch.getTooltip()
  }

  tooltipHide() {
    const t = this.getTooltip()
    if (t != null) {
      t.hide()
    } else {
      console.log('Tooltip has not been set yet')
    }
  }

  tooltipMove(e: React.MouseEvent) {
    const t = this.getTooltip()
    if (t != null) {
      t.move(e)
    } else {
      console.log('Tooltip has not been set yet')
    }
  }

  tooltipShow(text: string) {
    const t = this.getTooltip()
    if (t != null) {
      t.show(text)
    } else {
      console.log('Tooltip has not been set yet')
    }
  }

  onClickFunc() {
    this.tooltipHide()
    const s: SongFromJson = SongObjectToJson(this.props.song)
    this.props.outerSearch.pushItemToPlaylist(s)
    // addToList("s_" + this.props.song.hash)
    this.props.refreshHandler()
  }

  mouseOverFunc(e: React.MouseEvent) {
    this.tooltipMove(e)
    const item = this.props.song

    if (typeof item !== 'undefined') {
      const itemplays = (typeof item.plays !== 'undefined')
        ? ("<b>Plays:</b> " + item.plays + "<br/><b>Last Played:</b>" + item.last_played)
        : "<i>Song hasn't recently been played</i>"
      this.tooltipShow(itemplays + "<br/><b>Date added:</b>" + item.date_added)
    } else {
      this.tooltipShow("No song information available.")
    }

  }

  render() {
    const item = this.props.song

    return (
      <a onMouseOver={(e) => this.mouseOverFunc(e)} onMouseOut={this.tooltipHide}
        onClick={this.onClickFunc}>
        {item.title}
      </a>
    )
  }
}


