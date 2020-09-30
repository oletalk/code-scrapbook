import React from 'react';

class SongLink extends React.Component {
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
    return this.props.outerSearch.tooltipBox;
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

export default SongLink;
