import Nav from '../components/Nav'
import { doFetch } from '../common/fetch'
import { useState, useEffect, useCallback } from 'react'
import { nullSafeContains } from '../common/types'
import { NavType, DocumentInfo, SenderInfo, TagObject } from '../common/types-class'
import ViewDocumentInfo from '../components/DocumentInfo'
import FilterBox from '../components/FilterBox'
import { BACKEND_URL } from '../common/constants'
import { FilterState, SortOrder } from '../common/interfaces'
import SortColumn from '../components/SortColumn'
type documentbox = {
  info: DocumentInfo,
  colour: string,
  filtered: boolean
}

type sortingorder = {
  columnName: string,
  sortOrder: SortOrder | undefined
}

function ViewDocuments() {

  const [ documents, setDocuments ] = useState<documentbox[]>([])
  const [ sorting, setSorting ] = useState<sortingorder[]>()
  const [ filters, setFilter ] = useState<FilterState>({
    search: '',
    fromDate: '',
    toDate: ''
  })

  const getColour = (taglist : Map<string,TagObject[]>, senderId : string) : string => {
    let ret : string = ''
    let colour = taglist.get(senderId)?.at(0)?.color
    if (typeof colour !== 'undefined') {
      ret = colour
    }
    return ret
  }

  const shouldFilter = (doc : DocumentInfo, fstr : string) : boolean => {
    // filter on type/sender/
    let match = false
    if (nullSafeContains(doc.doc_type.name, fstr)) {
      match = true
    }
    if (nullSafeContains(doc.sender.name, fstr)) {
      match = true
    }
    if (nullSafeContains(doc.summary, fstr)) {
      match = true
    }
  
    return !match
  }

  const changeSortOrder = (colName: string, order: SortOrder | undefined) => {
    // set the general sort order (can only sort on one column at a time)
    let newState : sortingorder[] = []
    newState.push({
      columnName: colName,
      sortOrder: order
    })
    setSorting(newState)
  }

  const sortOrder = (colName: string) : SortOrder | undefined => {
    let ret : SortOrder | undefined = undefined
    if (typeof sorting !== 'undefined') {
      for (let i of sorting) {
        if (i.columnName === colName) {
          ret = i.sortOrder
        }
      }  
    }
    return ret
  }

  const sortFunc = (sorting : sortingorder[] | undefined) => {
    return (a: documentbox, b: documentbox) : number => { 
      let field1 = a.info.id
      let field2 = b.info.id
      if (typeof sorting !== 'undefined' && sorting.length > 0) {
        // look at the first one
        const sortingInfo = sorting[0]
        const colName = sortingInfo.columnName
        const order = sortingInfo.sortOrder
        console.log('sorting on ' + colName + ' ordering ' + order)
        if (typeof order !== 'undefined') {
          if (colName === 'date_rcvd') {
            field1 = sortField(order, true, a.info.received_date, b.info.received_date)
            field2 = sortField(order, false, a.info.received_date, b.info.received_date)
          } else if (colName === 'doc_type') {
            field1 = sortField(order, true, a.info.doc_type.name, b.info.doc_type.name)
            field2 = sortField(order, false, a.info.doc_type.name, b.info.doc_type.name)
          } else if (colName === 'sender') {
            field1 = sortField(order, true, a.info.sender.name, b.info.sender.name)
            field2 = sortField(order, false, a.info.sender.name, b.info.sender.name)
          } else {
            console.error("Unknown sort order '" + colName + "' -- please fix!")
          }  
        }
  
      }
      
      return field1.localeCompare(field2)
    }
  }

  const sortField = (ordr: SortOrder, onLHS: boolean, a: string, b: string) => {
    if (ordr === SortOrder.ASC) {
      return onLHS ? a : b
    } else { // descending
      return onLHS ? b : a
    }
  }

  const fetchTagsAndDocuments = useCallback(() => {
        // FETCH TAGS
        doFetch<SenderInfo[]>(BACKEND_URL + '/json/sendertags')
        .then((tags) => {
          let taglist = new Map<string,TagObject[]>()
          tags.forEach(tag => {
            taglist.set(tag.id, tag.sender_tags)
          })
          return taglist
        })
    .then((taglist) => {

      // FETCH DOCUMENTS
      // filter on dates if requested
      const extraFilter = 
          (filters.fromDate && filters.toDate) 
          ? '/' + filters.fromDate + '/' + filters.toDate 
          : ''

      console.log(' need to add this to url: ' + extraFilter)
      // if search string is there, use it to filter
      // TODO
      let searchStr = ''
      if (filters.search.length >=3) {
        searchStr = filters.search
      }

      // and fetch documents
      doFetch<DocumentInfo[]>(BACKEND_URL + '/documents' + extraFilter)
      .then((allDocs) => {
        let documentmap: documentbox[] = allDocs.map(
          doc => {
            return {
              info: doc,
              colour: getColour(taglist, doc.sender.id),
              filtered: shouldFilter(doc, searchStr)
            }
          }
        )
        setDocuments(documentmap)
        // marryTags(taglist)
      })
    })


  }, [filters])

  useEffect(() => {
    fetchTagsAndDocuments()
  }, [fetchTagsAndDocuments])

  // TODO - marry tags to ViewDocumentInfo
  return (
    <div>
      <Nav page={NavType.Documents} />
      <div className='advice'>Warning: account numbers are shown in this screen so be careful if you are accessing this site in a public place.</div>
      <FilterBox 
          filter={filters} 
          onChange={(f: FilterState) => setFilter(f)} />
          <div className='titlefixed'>
            <div className='titlerow'>
              <span className='date_rcvd doc_title'>Received <SortColumn sorting={sortOrder('date_rcvd')} name='date_rcvd' onToggle={changeSortOrder}/></span>
              <span className='doc_type doc_title'>Type<SortColumn sorting={sortOrder('doc_type')} name='doc_type' onToggle={changeSortOrder}/></span>
              <span className='doc_sender doc_title'>Sender<SortColumn sorting={sortOrder('sender')} name='sender' onToggle={changeSortOrder}/></span>
              <span className='date_rcvd doc_title'>Due</span>
              <span className='date_rcvd doc_title'>Paid</span>
              <span className='doc_account doc_title'>Account</span>
              <span className='doc_summary doc_title'>Summary</span>
            </div>
          </div>
          <div className='verticalspacer'>
            &nbsp;
          </div>
      {documents.sort(sortFunc(sorting)).map((doc, index) => {
        return doc.filtered ? 
        (<div className='hidden'>(hidden)</div>) : (
        <ViewDocumentInfo colour={doc.colour} index={index} info={doc.info} />
      )})}
      </div>
  )
}

export default ViewDocuments;