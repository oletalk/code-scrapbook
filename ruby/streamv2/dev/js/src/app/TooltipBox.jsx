import React from 'react';

class TooltipBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      content: '',
      visibOuter: 'tooltip',
      visibInner: 'tooltip',
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
      visibOuter: 'tooltip',
      visibInner: 'tooltiptext'
    });
  }

  show(text) {
    //console.log(' -> received show() message');
    this.setState({
      content: text,
      visibOuter: 'tooltipshow',
      visibInner: 'tooltipshow'
    });
  }


  render() {
    var top = (this.state.y + 20) + 'px';
    // according to https://reactjs.org/docs/dom-elements.html
    // setting innerHTML is dangerous
    var tooltipText = {__html: this.state.content};

    return (
      <div id='song_tooltip_container' className={this.state.visibOuter}
          style={{position:'absolute', top}}>
        <span id='song_tooltip' className={this.state.visibInner}
        dangerouslySetInnerHTML={tooltipText} />
      </div>
    );
  }
}

export default TooltipBox;
