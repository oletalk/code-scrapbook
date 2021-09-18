import * as React from 'react';
import SongLink from './SongLink';
import Search from './Search';
import { itemAlreadyInPlaylist } from './js/playlist_ui.js'

// TODO: convert playlist_util.js to ts so i can get rid of DSType!
type Song = {
  hash: string
  last_played: string
  plays: number
  title: string
  date_added: string
  derived: string
}
type LineItemProps = {
  dataSource: Song // this comes from playlist_util.js
  outerSearch: Search
}


export default class LineItem extends React.Component<LineItemProps> {
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

// export default LineItem;
