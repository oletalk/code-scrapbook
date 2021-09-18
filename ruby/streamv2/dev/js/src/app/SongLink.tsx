import * as React from 'react';
// import * as PropTypes from 'prop-types';
import Search from './Search'
import { addToList } from './js/playlist_ui.js'

type Song = {
  hash: string
  last_played: string
  plays: number
  title: string
  date_added: string
}
type SongLinkProps = {
  outerSearch: Search
  song: Song
  // see https://stackoverflow.com/questions/57510552/react-prop-types-with-typescript-how-to-have-a-function-type
  refreshHandler: Function
  
}

export default class SongLink extends React.Component<SongLinkProps> {
  constructor(props) {
    super(props);
    if (this.props.outerSearch == null) {
      console.warn('outerSearch is null! no link back to outer Search component.');
    }
    this.mouseOverFunc = this.mouseOverFunc.bind(this);
    this.onClickFunc = this.onClickFunc.bind(this);
    this.tooltipHide = this.tooltipHide.bind(this);
    this.tooltipMove = this.tooltipMove.bind(this);
    this.tooltipShow = this.tooltipShow.bind(this);
    //this.getTooltip  = this.getTooltip.bind(this);

  }

  getTooltip() {
    return this.props.outerSearch.getTooltip()
  }

  tooltipHide() {
    this.getTooltip().hide();
  }

  tooltipMove(e) {
    this.getTooltip().move(e);
  }

  tooltipShow(text) {
    this.getTooltip().show(text);
  }

  onClickFunc() {
    this.tooltipHide();
    addToList("s_" + this.props.song.hash);
    this.props.refreshHandler();
  }

  mouseOverFunc(e) {
    this.tooltipMove(e);
    let item = this.props.song;

    if (typeof item !== 'undefined') {
      let itemplays = (typeof item.plays !== 'undefined')
          ? ("<b>Plays:</b> " + item.plays + "<br/><b>Last Played:</b>" + item.last_played)
          : "<i>Song hasn't recently been played</i>"
      this.tooltipShow(itemplays + "<br/><b>Date added:</b>" + item.date_added);
    } else {
      this.tooltipShow("No song information available.");
    }

  }

  render() {
    let item = this.props.song;

    return (
        <a onMouseOver={(e) => this.mouseOverFunc(e) } onMouseOut={this.tooltipHide}
           onClick={this.onClickFunc}>
          {item.title}
        </a>
    );
  }
}


