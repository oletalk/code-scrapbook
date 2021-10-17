import * as React from 'react'

type LiLinkProps = {
  text: string,
  callback: () => void
}

export default class LiLink extends React.Component<LiLinkProps> {
  constructor(props: any) {
    super(props)
  }

  render() {
    return (
      <span className="taglist_item">
        <a className="tag-link" href="#"
          onClick={this.props.callback}>{this.props.text}</a>
      </span>
    )
  }
}

