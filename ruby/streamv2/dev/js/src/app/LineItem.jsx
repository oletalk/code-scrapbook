import React from 'react';
import SongLink from './SongLink.jsx';
import PropTypes from 'prop-types';


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

LineItem.propTypes = {
  dataSource: PropTypes.object.isRequired,
  outerSearch: PropTypes.object.isRequired,
}

export default LineItem;
