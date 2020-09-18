import React from 'react';

class SongLink extends React.Component {
  render() {
    let item = this.props.song;
    return (
        <a onMouseOver={this.positionTooltip}>
          {this.props.title}
        </a>
    );
  }
}

export default SongLink;
