import { AccountInfo, SelectFromListOfNamedTypes } from '../common/types-class'


function AccountSelectBox(props: SelectFromListOfNamedTypes<AccountInfo>) {

  const itemList = props.itemList
  const noItemMessage: string = props.noItemMessage !== undefined ? props.noItemMessage : 'no items available'

  const rtnObj = (selId : string) : AccountInfo | undefined  => {
    if (itemList !== undefined) {
      for (const item of itemList) {
        if (item.id === selId) {
          return item
        }
      }
    } 
  }
  if (typeof itemList === 'undefined' || itemList.length === 0) {
    return (
      <div>{noItemMessage}</div>
    )
  } else {
      return(
      <select 
            onChange={(e) => props.changeCallback(rtnObj(e.currentTarget.value))}
            className='sender_account_field' 
            name={props.selectName}>
      <option value="">- none -</option>s
      {itemList.map(s => (<option 
          selected={s.id === props.selectedItem}
          value={s.id}>{s.account_number}</option>))}
      </select>
  )

  }
}

export default AccountSelectBox