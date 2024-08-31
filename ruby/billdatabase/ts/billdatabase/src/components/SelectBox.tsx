import { NamedType, SelectFromListOfNamedTypes } from '../common/types-class'


function SelectBox<T extends NamedType>(props: SelectFromListOfNamedTypes<T>) {

  const isMandatory = !(props.mandatory === undefined || props.mandatory === false)
  const firstOptionName = isMandatory ? '- mandatory, please select -' : '- none -'
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
    <option value="">{ firstOptionName }</option>
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