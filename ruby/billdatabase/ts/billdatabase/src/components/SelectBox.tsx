import { NamedType, SelectFromListOfNamedTypes } from '../common/types-class'


function SelectBox<T extends NamedType>(props: SelectFromListOfNamedTypes<T>) {

  // TODO: onChange handler
  const itemList = props.itemList
  const noItemMessage: string = props.noItemMessage !== undefined ? props.noItemMessage : 'no items available'

  const rtnObj = (selId : string) : T | undefined  => {
    if (itemList !== undefined) {
      for (const item of itemList) {
        if (item.id === selId) {
          return item
        }
      }
    } 
  }

  return(
    <select 
          onChange={(e) => props.changeCallback(rtnObj(e.currentTarget.value))}
          className='sender_field' 
          name={props.selectName}>
    <option value="">- none -</option>
    {itemList 
      ? itemList.map(s => (<option 
            value={s.id}
            selected={s.id === props.selectedItem}
            >{s.name}</option>))
      : <div>{noItemMessage}</div>}
    </select>

  )
}

export default SelectBox