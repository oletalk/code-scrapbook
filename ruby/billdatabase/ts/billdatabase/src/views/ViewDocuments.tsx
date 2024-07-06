import Nav from '../components/Nav'
import { doFetch } from '../common/fetch'
import { useState, useEffect, useCallback } from 'react'
import { nullSafeContains } from '../common/types'
import { NavType, DocumentInfo, SenderInfo, TagObject } from '../common/types-class'
import ViewDocumentInfo from '../components/DocumentInfo'
import FilterBox from '../components/FilterBox'
import { BACKEND_URL } from '../common/constants'
import { FilterProps, FilterState } from '../common/interfaces'
type documentbox = {
  info: DocumentInfo,
  colour: string,
  filtered: boolean
}


function ViewDocuments() {

  const [ documents, setDocuments ] = useState<documentbox[]>([])
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

  const getFilterString = () : string => {
    // do the date filtering
    if (!filters.fromDate || !filters.toDate) {
      return ''
    } else {
      return '/' + filters.fromDate + '/' + filters.toDate
    }
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
      let extraFilter = getFilterString()
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
              <span className='date_rcvd doc_title'>Received</span>
              <span className='doc_type doc_title'>Type</span>
              <span className='doc_sender doc_title'>Sender</span>
              <span className='date_rcvd doc_title'>Due</span>
              <span className='date_rcvd doc_title'>Paid</span>
              <span className='doc_account doc_title'>Account</span>
              <span className='doc_summary doc_title'>Summary</span>
            </div>
          </div>
          <div className='verticalspacer'>
            &nbsp;
          </div>
      {documents.map((doc, index) => {
        return doc.filtered ? 
        (<div className='hidden'>(hidden)</div>) : (
        <ViewDocumentInfo colour={doc.colour} index={index} info={doc.info} />
      )})}
      </div>
  )
}

export default ViewDocuments;