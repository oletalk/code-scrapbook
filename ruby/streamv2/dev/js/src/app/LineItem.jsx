import React from 'react';
import SongLink from './SongLink.jsx';


class LineItem extends React.Component {
  constructor(props) {
    super(props);
    this.refreshHandler = this.refreshHandler.bind(this);
  }

  refreshHandler() {
    this.forceUpdate();
  }

  render() {
    let item = this.props.dataSource;
    return (itemAlreadyInPlaylist('s_' + item.hash) ?
      (
        <li id={'s_' + item.hash}>{item.title}</li>
      )
      :
      (
        <li id={'s_' + item.hash} className={'title_' + item.derived}>
          <SongLink outerSearch={this.props.outerSearch} song={item} refreshHandler={this.refreshHandler} />
        </li>
      )
    );


  }
}

export default LineItem;
