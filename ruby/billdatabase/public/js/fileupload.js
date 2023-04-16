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
          console.error('Problem ' + operation + ': ' + response.data.result)
        } else {
          alert('document deleted!')
        }
      })
      .catch((error) => {
        console.error(error)
      })
  }
}

function uploadFile(elementId, docId) {
  const fileInput = document.getElementById(elementId)
  console.log('uploadFile called for doc ' + docId)
  var reader = new FileReader()
  reader.onload = function (e) {
    // format reader.result for upload
    const data = {
      name: fileInput.files[0].name,
      data: reader.result
    }
    axios.post('/document/' + docId + '/file', data)
      .then((response) => {
        if (typeof response.data.result !== 'undefined' && response.data.result !== 'success') {
          console.error('Problem ' + operation + ': ' + response.data.result)
        } else {
          alert('document uploaded.')
        }
      })
      .catch((error) => {
        console.error(error)
      })

  }
  reader.readAsText(fileInput.files[0])
}