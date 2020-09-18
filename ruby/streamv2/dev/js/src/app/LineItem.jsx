import React from 'react';

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

    return (
      <li id={'s_' + item.hash}>{item.title}</li>
    );

  }
}

export default LineItem;
