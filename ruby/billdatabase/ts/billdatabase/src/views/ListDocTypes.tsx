import Nav from "../components/Nav"
import { NavType } from '../common/types-class'
import { DocumentType } from "../common/types-class"
import { useEffect, useState, useCallback } from "react"
import { doFetch } from "../common/fetch"
import { BACKEND_URL } from "../common/constants"

function ListDocTypes() {

  const [ docTypes, setDocTypes ] = useState<DocumentType[]>()


  const fetchDocTypes = useCallback(() => {
    // FETCH DOCUMENT INFO
    doFetch<DocumentType[]>(BACKEND_URL + '/doctypes')
    .then((json) => {
      setDocTypes(json)
      console.log('done...') 
      })
      .catch((err) => {
        console.error(err)
      })
   }, [])
 
 
    // 'onMounted'...
    useEffect(() => {
      fetchDocTypes()
   
    }, [fetchDocTypes])
  if (typeof docTypes !== 'undefined' && docTypes.length > 0) {
    return (
      <div>
      <Nav page={NavType.DocumentTypes} />
      <div>
        <h2>List of Document Types</h2>
        <ul>
        {docTypes.map(dt => <li>
          {dt.name}
        </li>)}
      </ul>
      </div>
      </div>
    )
  } else {
    return (
      <div>No DocTypes defined yet</div>
    )
  }

}

export default ListDocTypes