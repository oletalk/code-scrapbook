import Nav from '../components/Nav'
import { Calendar, dayjsLocalizer } from 'react-big-calendar'
import "react-big-calendar/lib/css/react-big-calendar.css";
import { useNavigate } from "react-router-dom";

import dayjs from 'dayjs'
import { doFetch } from '../common/fetch'
import { useState, useEffect, useCallback } from 'react'
import { nullSafeContains } from '../common/types'
import { NavType, DocumentInfo, SenderInfo, TagObject, EventType } from '../common/types-class'
import ViewDocumentInfo from '../components/DocumentInfo'
import FilterBox from '../components/FilterBox'
import { BACKEND_URL } from '../common/constants'
import { FilterState, SortOrder, DocColName, ViewMode } from '../common/interfaces'
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

  const navigate = useNavigate();
  const localizer = dayjsLocalizer(dayjs)
  const [ selectedDocument, setSelectedDocument ] = useState<DocumentInfo>()
  const [ documents, setDocuments ] = useState<documentbox[]>([])
  const [ screenMode, setScreenMode ] = useState<ViewMode>(ViewMode.NORMAL)
  const [ sorting, setSorting ] = useState<sortingorder[]>(
    [{columnName:'date_rcvd', sortOrder: SortOrder.DESC}] /* default sort order */
  )
  const [ filters, setFilter ] = useState<FilterState>({
    search: '',
    fromDate: '',
    toDate: ''
  })
  let myEventsList : EventType[] = []

  // functions
  const getColour = (taglist : Map<string,TagObject[]>, senderId : string) : string => {
    let ret : string = ''
    let colour = taglist.get(senderId)?.at(0)?.color
    if (typeof colour !== 'undefined') {
      ret = colour
    }
    return ret
  }

  const swapView = (newView : ViewMode) => {
    setScreenMode(newView)
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
        // console.log('sorting on ' + colName + ' ordering ' + order)
        if (typeof order !== 'undefined') {
          if (colName === DocColName.RCVD) {
            field1 = sortField(order, true, a.info.received_date, b.info.received_date)
            field2 = sortField(order, false, a.info.received_date, b.info.received_date)
          } else if (colName === DocColName.DOC_TYPE) {
            field1 = sortField(order, true, a.info.doc_type.name, b.info.doc_type.name)
            field2 = sortField(order, false, a.info.doc_type.name, b.info.doc_type.name)
          } else if (colName === DocColName.SENDER) {
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

  const toEvent = (doc: documentbox, ind: number) : EventType => {
    let rcvddate = doc.info.received_date
    const startdate = new Date(rcvddate)
    let enddate = new Date(rcvddate)
    enddate.setDate(enddate.getDate() + 1)
    
    return {
      id: parseInt(doc.info.id), // ind,
      title: doc.info.summary,
      start: startdate,
      end: enddate
    }
  }

  const sortField = (ordr: SortOrder, onLHS: boolean, a: string, b: string) => {
    if (ordr === SortOrder.ASC) {
      return onLHS ? a : b
    } else { // descending
      return onLHS ? b : a
    }
  }

  const selectNoDoc = () => {
    setSelectedDocument(undefined)
  }

  const handleSelectedEvent = (event : EventType) => {
    const dbox = documents.find(d => parseInt(d.info.id) === event.id)
    if (typeof dbox !== 'undefined') {
      setSelectedDocument(dbox.info)
      console.log('document id = ' + dbox.info.id)
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
if (screenMode === ViewMode.NORMAL) {
  return (
    <div>
      <Nav page={NavType.Documents} />
      <div className='swapviews'>
      <span><b>Normal</b> | <button onClick={() => swapView(ViewMode.CALENDAR)}>Calendar view</button></span>
      </div>
      <div className='advice'>Warning: account numbers are shown in this screen so be careful if you are accessing this site in a public place.</div>
      <FilterBox 
          filter={filters} 
          onChange={(f: FilterState) => setFilter(f)} />
          <div className='titlefixed'>
            <div className='titlerow'>
              <span className='date_rcvd doc_title'>Received <SortColumn sorting={sortOrder(DocColName.RCVD)} name={DocColName.RCVD} onToggle={changeSortOrder}/></span>
              <span className='doc_type doc_title'>Type<SortColumn sorting={sortOrder(DocColName.DOC_TYPE)} name={DocColName.DOC_TYPE} onToggle={changeSortOrder}/></span>
              <span className='doc_sender doc_title'>Sender<SortColumn sorting={sortOrder(DocColName.SENDER)} name={DocColName.SENDER} onToggle={changeSortOrder}/></span>
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
} else {
  // TEST
 /* myEventsList[0] = {
    id: 0,
    title: "event #1",
    start: new Date("2025-01-10"),
    end: new Date("2025-01-11")
  } */
  myEventsList = documents.map((doc, index) => toEvent(doc, index))

  return (
    <div>
      <Nav page={NavType.Documents} />
      <div className='swapviews'>
        <span><button onClick={() => swapView(ViewMode.NORMAL)}>Normal</button> | <b>Calendar view</b></span>
        <div>
          {typeof selectedDocument !== 'undefined' ? (<ViewDocumentInfo closeCallback={selectNoDoc} format='compact' colour='#000' info={selectedDocument} index={1} />) : <div>&nbsp;</div>}
 
        <Calendar
        onSelectEvent={(event) => handleSelectedEvent(event)}
      localizer={localizer}
      events={myEventsList}
      startAccessor="start"
      endAccessor="end"
      style={{ height: 500 }}
    />
        </div>
      </div>
  </div>
  )
}
}
         /*        ViewDocumentInfo colour={doc.colour} index={index} info={doc.info} 
          */

export default ViewDocuments;