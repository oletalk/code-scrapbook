import { TagObject } from "../common/types-class"
import { useState, useEffect, useCallback } from 'react'

interface TagProps {
  tags: TagObject[],
  filterCallbackOn: (activeIds : string[]) => void
}
interface tagfilter {
  info: TagObject,
  filtering: boolean
}
interface TagFilterState {
  filters: tagfilter[]
}

function TagFilter(props: TagProps) {

  const tagList = props.tags
  const [ tagFilters, setTagFilters ] = useState<TagFilterState>()

  useEffect(() => {
    setTagFilters({
      filters: tagList.map(tag => ({
        info: tag,
        filtering: false
      }))
    })
  
  }, [tagList])

  // TODO : better retrieval of this point
  const isFiltering = (tagid: string) : boolean => {
    if (typeof tagFilters !== 'undefined') {
      for (let f of tagFilters.filters)
        if (f.info.id === tagid && f.filtering) {
          return true
        }
        return false
    } else {
      return false
    }
  }

  const doFilterOnTag = (tagid : string) => {
    if (typeof tagFilters !== 'undefined') {
      console.log('doFilterOnTag ' + tagid)
      let changed = false
      const newState : tagfilter[] = tagFilters.filters
      for (let f of newState) {
        if (f.info.id === tagid) {
          f.filtering = !f.filtering
          changed = true
        }
      }
      if (changed) {
        setTagFilters({
          filters: newState
        })
        let ids : string[] = newState.filter(tf => tf.filtering)
            .map(tf => (tf.info.id))
        props.filterCallbackOn(ids)
      }
    }
  }

  if (typeof tagList === 'undefined') {
    return (
      <p>no tags loaded yet</p>
    )
  } else {
    return (
      <p>
        <ul>
        {tagList.map(tag => 
          <button 
              className={isFiltering(tag.id) ? 'tagFilterList-Active' : 'tagFilterList'} 
              onClick={() => doFilterOnTag(tag.id)}>{tag.description}</button>
        )}
      </ul>
      </p>
   
    )
  }


}

export default TagFilter