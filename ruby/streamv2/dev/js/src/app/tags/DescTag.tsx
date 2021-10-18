import * as React from 'react'

type TagProps = {
  tag_id: number,
  tag_desc: string,
  callback: () => void
}

export default class DescTag extends React.Component<TagProps> {
  constructor(props: any) {
    super(props)

  }

  render() {
    return (
      <span className="taglist-item" key={this.props.tag_id}>
        <a className="tag-link" href="#"
          onClick={this.props.callback}> <span className="tag-link-small">x</span> </a> {this.props.tag_desc}
      </span>
    )
  }
}

