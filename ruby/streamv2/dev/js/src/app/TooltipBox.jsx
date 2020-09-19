import React from 'react';

class TooltipBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      content: '',
      visib: 'tooltip',
      y: 200
    };
    this.hide = this.hide.bind(this);
    this.show = this.show.bind(this);
    this.move = this.move.bind(this);

    this.props.outerSearch.tooltipBox = this;
  }

  move(e) {
    this.setState({
      y: e.clientY
    });
  }

  hide() {
    this.setState({
      content: '',
      visib: 'tooltip'
    });
  }

  show(text) {
    console.log(' -> received show() message');
    console.log('    content: ' + text);
    this.setState({
      content: text,
      visib: 'tooltipshow'
    });
  }


  render() {
    var divStyle = {
        position: 'absolute',
        top: (this.state.y + 20) + 'px'
      };
    return (
      <div id='song_tooltip_container' className={this.state.visib} style={divStyle}>
        <span id='song_tooltip' className={this.state.visib}>
          {this.state.content.value}
        </span>
      </div>
    );
  }
}

export default TooltipBox;
