function go(url) {
  window.location.replace(url)
}

function toggleShowAccount() {
  let sa = document.getElementById('newaccount')
  sa.classList.toggle('hidden')
}

function addSender() {
  const data = collectElementsOfFrom('sender_field', document)
  if (typeof data !== 'undefined') {
    axios.post('/sender_new', data)
      .then((response) => {
        const new_id = response.data.id
        if (typeof new_id !== 'undefined') {
          console.log(response.data)
          window.location.replace('/sender/' + new_id)
        } else {
          console.error('no new id returned - save did not work')
        }
      })
      .catch((error) => {
        console.error(error)
      })
  }
}

function updateSender(sid) {
  const data = collectElementsOfFrom('sender_field', document)
  if (typeof data !== 'undefined') {
    console.log(JSON.stringify(data))
    axios.post('/sender/' + sid, data)
      .then((response) => {
        console.log(response.data)
        location.reload()
      })
      .catch((error) => {
        console.error(error)
      })
  }
}

function addAccount(sender_id) {
  const containerDiv = document.getElementById('account_new')
  let data = collectElementsOfFrom('fieldval', containerDiv)
  if (typeof data !== 'undefined') {
    data['sender_id'] = sender_id
    console.log(JSON.stringify(data))
    axios.post('/sender/' + sender_id + '/account_new', data)
      .then((response) => {
        console.log(response.data)
        location.reload()
      })
      .catch((error) => {
        console.error(error)
      })
  }
}

function fetchSenderAccounts(sender_id) {
  axios.get('/json/sender/' + sender_id + '/accounts')
    .then((response) => {
      const data = response.data
      const accBox = document.getElementById('senderaccounts')
      removeAllOptions(accBox)
      accBox.appendChild(createOption('none', '- none -'))
      for (let acc of data) {
        // console.log(acc.id + ': ' + acc.account_number)
        const opt = createOption(acc.id, acc.account_number)
        accBox.appendChild(opt)


      }
      // need to regenerate select options based on the elements
    })
    .catch((error) => {
      console.error(error)
    })
}

function markChanged(target) {
  if (!target.classList.contains('field_changed')) {
    target.classList.add('field_changed')
  }
}
function deleteAccount(sa_id) {
  if (confirm('Are you sure??')) {
    axios.delete('/senderaccount/' + sa_id)
      .then((response) => {
        location.reload()
        console.log(response.data)
      })
      .catch((error) => {
        console.error(error)
      })

  }

}
function updateAccount(topEl) {
  const containerDiv = document.getElementById(topEl)
  const data = collectElementsOfFrom('fieldval', containerDiv)

  if (typeof data !== 'undefined') {
    console.log(JSON.stringify(data))
    axios.post('/senderaccount/' + data.id, data)
      .then((response) => {
        location.reload()
        console.log(response.data)
      })
      .catch((error) => {
        console.error(error)
      })

  }

}

// utility methods
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
      console.log(field.name)
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

