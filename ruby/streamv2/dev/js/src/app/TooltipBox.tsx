import * as React from 'react'
import Search from './Search'

type TooltipBoxProps = {
  outerSearch: Search
}
type TooltipBoxState = {
  content: string
  visibOuter: string
  visibInner: string
  y: number

}
export default class TooltipBox extends React.Component<TooltipBoxProps, TooltipBoxState> {
    constructor(props: any) {
    super(props)
    this.state = {
      content: '',
      visibOuter: 'tooltip',
      visibInner: 'tooltip',
      y: 200
    }
    this.hide = this.hide.bind(this)
    this.show = this.show.bind(this)
    this.move = this.move.bind(this)

    // this.props.outerSearch.tooltipBox = this;
    this.props.outerSearch.setTooltip(this)
  }

  move(e: React.MouseEvent) {
    this.setState({
      y: e.clientY
    })
  }

  hide() {
    this.setState({
      content: '',
      visibOuter: 'tooltip',
      visibInner: 'tooltiptext'
    })
  }

  show(text: string) {
    //console.log(' -> received show() message');
    this.setState({
      content: text,
      visibOuter: 'tooltipshow',
      visibInner: 'tooltipshow'
    })
  }


  render() {
    var top = (this.state.y + 20) + 'px'
    // according to https://reactjs.org/docs/dom-elements.html
    // setting innerHTML is dangerous
    var tooltipText = {__html: this.state.content}

    return (
      <div id='song_tooltip_container' className={this.state.visibOuter}
          style={{position:'absolute', top}}>
        <span id='song_tooltip' className={this.state.visibInner}
        dangerouslySetInnerHTML={tooltipText} />
      </div>
    )
  }
}

