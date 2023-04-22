function downloadFile(docId) {
  axios.get('/document/' + docId + '/file')
    .then((response) => {
      if (typeof response.data.result !== 'undefined' && response.data.result !== 'success') {
        console.error('Problem ' + operation + ': ' + response.data.result)
      } else {
        alert('document downloaded!')
      }
    })
    .catch((error) => {
      console.error(error)
    })

}

function deleteFile(docId) {
  if (confirm('This cannot be undone. Are you sure?')) {
    axios.delete('/document/' + docId + '/file')
      .then((response) => {
        if (typeof response.data.result !== 'undefined' && response.data.result !== 'success') {
          console.error('Problem deleting file: ' + response.data.result)
        } else {
          alert('document deleted!')
          location.reload()
        }
      })
      .catch((error) => {
        console.error(error)
      })
  }
}

function uploadFile(elementId, docId) {
  const file = document.getElementById(elementId).files[0]
  console.log('uploadFile called for doc ' + docId)
  let formData = new FormData()

  formData.append('file', file)

  // POST to /document/<docId>/file
  // i give up on axios/json for uploads, using fetch instead
  fetch('/document/' + docId + '/file', {
    method: "POST",
    body: formData
  })
    .then((response) => {
      if (response.ok) {
        location.reload()
      } else {
        console.error('Problem uploading file: ')
        console.log('HTTP status: ' + response.status + ' ' + response.statusText)
      }
    })
    .catch((error) => {
      console.error(error)
    })
}