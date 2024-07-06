import { FilterProps } from '../common/interfaces'

function FilterBox(props: FilterProps) {

  return (
    <div className='searchbar'>
      <span className='searchtitle'>Search type/sender/summary: 
        <input 
            onChange={(e) => props.onChange({...props.filter, search: e.target.value})}  
            type='text' value={props.filter.search}/>
      </span>
      <span>From:
        <input 
            onChange={(e) => props.onChange({...props.filter, fromDate: e.target.value})}  
            type='date' value={props.filter.fromDate}/>
      </span>
      <span>To:
        <input 
            onChange={(e) => props.onChange({...props.filter, toDate: e.target.value})}  
            type='date' value={props.filter.toDate}/>
      </span>
    </div>
  )
}

export default FilterBox