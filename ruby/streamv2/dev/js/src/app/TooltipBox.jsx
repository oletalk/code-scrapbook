import React from 'react';

class TooltipBox extends React.Component {
  render() {
    return (
      <div id='song_tooltip_container' className='tooltip' >
        <span id='song_tooltip' className='tooltiptext' />
      </div>
    );
  }
}

export default TooltipBox;
