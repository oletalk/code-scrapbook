function go(url) {
  window.location.replace(url)
}
function openwindow(url) {
  window.open(url)
}

function markChanged(target) {
  if (!target.classList.contains('field_changed')) {
    target.classList.add('field_changed')
  }
}

function addDocument() {
  const docInfo = collectElementsOfFrom('sender_field', document)
  console.log(docInfo)
  if (typeof docInfo !== 'undefined') {
    axios.post('/document_new', docInfo)
      .then((response) => {
        const new_id = response.data.id
        if (typeof new_id !== 'undefined') {
          console.log(response.data)
          window.location.replace('/document/' + new_id)
        } else {
          if (typeof response.data.result !== 'undefined') {
            console.error('Problem saving document: ' + response.data.result)
          } else {
            console.error('no new id returned - save did not work')
          }
        }
      })
      .catch((error) => {
        console.error(error)
      })
  }
}

function updateDocument(id) {
  const docInfo = collectElementsOfFrom('sender_field', document)
  console.log(docInfo)
  // docInfo = undefined //test
  if (typeof docInfo !== 'undefined') {
    axios.post('/document/' + id, docInfo)
      .then((response) => reloadOrPrintError(response, 'updating document'))
      .catch((error) => {
        console.error(error)
      })

  }
}

// utility methods
function reloadOrPrintError(response, operation) {
  if (typeof response.data.result !== 'undefined' && response.data.result !== 'success') {
    console.error('Problem ' + operation + ': ' + response.data.result)
  } else {
    location.reload()
    console.log(response.data)
  }

}

function collectElementsOfFrom(className, containerElement) {
  let data = {}
  for (field of containerElement.getElementsByClassName(className)) {
    const val = field.value

    data[field.name] = val
    if (field.classList.contains('mandatory')) {
      console.log('field ' + field.name + ' is mandatory')
      if (typeof val === 'undefined' || val === '') {
        data = undefined
        alert('Mandatory field "' + field.name + '" is empty')
        break
      }
    }
  }

  return data
}

function removeAllOptions(selectBox) {
  while (selectBox.options.length > 0) {
    selectBox.remove(0)
  }
}
// helper function to create a new option
function createOption(val, txt) {
  const newOption = document.createElement('option')
  const optionText = document.createTextNode(txt)
  newOption.appendChild(optionText)
  newOption.setAttribute('value', val)
  return newOption
}

// we have to do this AFTER the document loaded
function addChangeIndicators(className) {
  for (let field of document.getElementsByClassName(className)) {
    // check it is an input or textarea
    if (field.nodeName == 'INPUT' || field.nodeName == 'TEXTAREA') {
      // console.log(field.name)
      field.addEventListener(
        'change',
        function () { markChanged(this) },
        false
      )
    }
  }
}

function getToday() {
  const d = new Date()
  return d.toISOString().split('T')[0]
}

function toggleShowSender(senderrow) {
  let sa0 = document.getElementById(senderrow + '_0')
  sa0.classList.toggle('hidden')
  let sa1 = document.getElementById(senderrow + '_1')
  sa1.classList.toggle('hidden')

}

