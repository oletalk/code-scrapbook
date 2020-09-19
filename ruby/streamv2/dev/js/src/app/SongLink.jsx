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

  }

  tooltipHide() {
    var linkedTooltip = this.props.outerSearch.tooltipBox;
    linkedTooltip.hide();
  }

  tooltipMove(e) {
    var linkedTooltip = this.props.outerSearch.tooltipBox;
    console.log('calling from SongLink');
    linkedTooltip.move(e);
  }

  tooltipShow(text) {
    var linkedTooltip = this.props.outerSearch.tooltipBox;
    linkedTooltip.show(text);
  }

  onClickFunc() {
    this.tooltipHide();
    addToList("s_" + this.props.song.hash);
    this.props.refreshHandler();
  }

  mouseOverFunc(e) {
    this.tooltipMove(e); // TODO: implement the tooltipMove, tooltipHide, tooltipShow functions
    let item = this.props.song;
    if (this.props.song !== undefined) {
      this.tooltipShow("<b>Plays:</b> " + item.plays
          + "<br/><b>Last Played:</b>" + item.last_played
          + "<br/><b>Date added:</b>" + item.date_added);
    } else {
      this.tooltipShow("Song was not recently played.");
    }

  }

  render() {
    let item = this.props.song;
    // TODO: remove tooltip code from playlist_util.js!
    return (
        <a onMouseOver={(e) => this.mouseOverFunc(e) } onMouseOut={this.tooltipHide}
           onClick={this.onClickFunc}>
          {item.title}
        </a>
    );
  }
}

export default SongLink;
