import * as React from 'react'

type LiLinkProps = {
  text: string,
  title: string,
  callback: () => void
}

export default class LiLink extends React.Component<LiLinkProps> {
  constructor(props: any) {
    super(props)
  }

  render() {
    return (
      <span className="taglist-item">
        <a title={this.props.title} className="tag-link" href="#"
          onClick={this.props.callback}>{this.props.text}</a>
      </span>
    )
  }
}

