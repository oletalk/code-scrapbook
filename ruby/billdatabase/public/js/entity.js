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

function loadDocs(sender_id, topElemName) {
  axios.get('/json/sender/' + sender_id + '/documents')
    .then((response) => {
      const docs = response.data
      // the TD inside this TR
      let TRelem = document.getElementById(topElemName)
      let elem = TRelem.firstElementChild
      let hasDocs = false
      for (const doc of docs) {
        let newdoc = document.createElement('div')
        newdoc.innerHTML = doc.received_date + ': ' + '<a href="/document/'
          + doc.id + '">' + doc.summary + '</a>'
        if (!hasDocs) {
          hasDocs = true
          elem.innerHTML = 'Documents<br/>'
        }
        elem.appendChild(newdoc)
      }
    })
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

function toggleSenderRow(senderrow, stat) {
  let saX = document.getElementById(senderrow + '_X')
  const goingToShow = stat

  let sa0 = document.getElementById(senderrow + '_0')
  let sa1 = document.getElementById(senderrow + '_1')
  let sa2 = document.getElementById(senderrow + '_2')

  if (goingToShow) {
    saX.classList.remove('hidden')
    sa0.classList.remove('hidden')
    sa1.classList.remove('hidden')
    sa2.classList.remove('hidden')
  } else {
    saX.classList.add('hidden')
    sa0.classList.add('hidden')
    sa1.classList.add('hidden')
    sa2.classList.add('hidden')
  }
}
function toggleShowSender(senderrow) {
  // user creds
  let sa0 = document.getElementById(senderrow + '_0')
  let goingToShow = false
  if (sa0.classList.contains('hidden')) {
    goingToShow = true
  }
  sa0.classList.toggle('hidden')
  // comments
  let sa1 = document.getElementById(senderrow + '_1')
  sa1.classList.toggle('hidden')
  // documents (if any)
  let sa2 = document.getElementById(senderrow + '_2')
  sa2.classList.toggle('hidden')

  if (goingToShow) {
    // fetch and show documents
    const sender_id = senderrow.split('_')[1]
    console.log('going to show documents for sender ' + sender_id)
    loadDocs(sender_id, senderrow + '_2')
  }
}

function toggleShowPaid(t) {
  let trs = document.getElementsByClassName('pmt_paid')
  for (tr of trs) {
    tr.classList.toggle('hidden')
  }
}

function loadAllTags(topElemName) {
  axios.get('/json/sendersbytag')
    .then((response) => {

      const topTR = document.getElementById(topElemName)
      const tags = response.data
      let hasTags = false
      for (const tag of Object.keys(tags)) {
        hasTags = true
        const idstr = tag.split('|')
        const text = tags[tag]
        const newLi = liof(newCheckbox(idstr[1], text), idstr[0])
        topTR.appendChild(newLi)
      }
      
      if (hasTags) {
        const selNone = document.createElement('button')
        selNone.innerHTML = 'Select None'
        selNone.addEventListener('click', () => {
          for (let li of document.getElementById(topElemName).childNodes) {
            if (li.firstElementChild != null) {
              if (li.firstElementChild.tagName == 'INPUT') {
                if (li.firstElementChild.checked) {
                  // deselect it
                  li.firstElementChild.click()
                }
              }
            }
          }

        })
        topTR.appendChild(selNone)
      }
      // the TD inside this TR

    })
}

function liof(el, text) {
  const ret = document.createElement('li')
  ret.appendChild(el)
  ret.appendChild(document.createTextNode(text))
  ret.addEventListener('click', selectSenders)
  return ret
}

function selectSenders(e) {
  console.log('selecting ')
  const ids = e.target.value
  const chk = e.target.checked
  console.log(ids + ' which are checked? ' + chk)
  const idlist = ids.split(',')
  for (const id of idlist) {
    console.log(id)
    toggleSenderRow('tr_' + id, chk)
  }
}

function newCheckbox(id, val) {
  const ret = document.createElement('input')
  ret.setAttribute('type', 'checkbox')
  ret.setAttribute('name', id)
  ret.setAttribute('value', val)
  ret.setAttribute('checked', true)
  return ret
}
