import { doDelete, doUpload } from '../common/fetch'
import { DocumentInfo } from '../common/types-class'
import { BACKEND_URL } from '../common/constants'

export type FileUploadProps = {
  documentInfo: DocumentInfo | undefined
}

function FileUploadSection(props: FileUploadProps) {

  const documentInfo = props.documentInfo

  const openFileInWindow = (docId : string | undefined) => {
    if (typeof docId === 'string') {
      window.open('/document/' + docId + '/file')
    }
  }

  const uploadFile = (elementId : string, docId : string | undefined) => {
    if (typeof docId !== 'undefined') {
      let fileupload = document.getElementById(elementId)
      if (fileupload !== null) {
        console.log('doing upload')
        doUpload('/document/' + docId + '/file', fileupload as HTMLInputElement) // any other way to do this?
        window.location.reload()
      }
    }
  }

  const hasFileLocation = (info : DocumentInfo | undefined) : boolean => {
    if (typeof info !== 'undefined') {
      const fileloc = info.file_location
      if (typeof fileloc !== 'undefined') {
        if (fileloc !== null && fileloc.trim() !== '') {
          return true
        }
      }
    }
    return false
  }

  const deleteFile = (docId : string | undefined) => {
    if (typeof docId === 'string') {
        if (window.confirm('This cannot be undone. Are you sure?')) {
          doDelete(BACKEND_URL + '/document/' + docId + '/file', 
            () => {
              alert('document deleted!')
              window.location.reload()
            }
          )
          }
        }
  }

  return ( 
  <div className='filesection'>
<label>Receipt photo/PDF:</label> 
      {hasFileLocation(documentInfo)
      ? <div>
        <span className="doc_filename">{documentInfo?.file_location}</span>
        <div className="fileops">
          <button className='icon icon-download' onClick={() => openFileInWindow(documentInfo?.id)}><img alt="download" src='/img/download.svg'/></button>
          <button className='icon icon-trash' onClick={() => deleteFile(documentInfo?.id)}><img alt="delete" src='/img/trash.svg'/></button>
        </div>

        </div>
      :       
      <div className="fileops"><input id='file_location' name='file_location' type='file' />
      <button onClick={() => uploadFile('file_location', documentInfo?.id)}>Upload</button></div>

 }
  
    </div>)
}

export default FileUploadSection