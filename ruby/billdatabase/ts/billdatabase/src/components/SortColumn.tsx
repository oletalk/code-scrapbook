import { SortColumnProps, SortOrder } from '../common/interfaces'
function SortColumn(props: SortColumnProps) {


  const toggle = () => {
    let newSorting : SortOrder | undefined
    if (typeof props.sorting === 'undefined') {
      newSorting = SortOrder.ASC
    } else {
      if (props.sorting === SortOrder.ASC) {
        newSorting = SortOrder.DESC
      } else {
        newSorting = undefined
      }
    }
    props.onToggle(props.name, newSorting)
  }

  const btnText = () => {
    if (typeof props.sorting === 'undefined') {
      return "-"
    } else {
      if (props.sorting === SortOrder.ASC) {
        return '^'
      } else {
        return 'V'
      }
    }
  }

  return (
      <span>
        <button onClick={(e) => toggle()} >{ btnText() }</button>
      </span>
  )
}

export default SortColumn