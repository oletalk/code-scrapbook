import { AccountInfo, SelectFromListOfNamedTypes } from '../common/types-class'


function AccountSelectBox(props: SelectFromListOfNamedTypes<AccountInfo>) {

  const itemList = props.itemList
  const noItemMessage: string = props.noItemMessage !== undefined ? props.noItemMessage : 'no items available'

  return(
    <select 
          onChange={(e) => props.changeCallback(e.currentTarget.value)}
          className='sender_account_field' 
          name={props.selectName}>
    <option value="">- none -</option>
    {itemList 
      ? itemList.map(s => (<option 
        selected={s.id === props.selectedItem}
        value={s.id}>{s.account_number}</option>))
      : <div>{noItemMessage}</div>}
    </select>

  )
}

export default AccountSelectBox