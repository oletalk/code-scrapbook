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
      .then((response) => reloadOrPrintError(response, 'updating sender'))
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
      .then((response) => reloadOrPrintError(response, 'adding account'))
      .catch((error) => {
        console.error(error)
      })
  }
}

function addContact(sender_id) {
  const containerDiv = document.getElementById('contact_new')
  let data = collectElementsOfFrom('fieldval', containerDiv)
  if (typeof data !== 'undefined') {
    data['sender_id'] = sender_id
    console.log(JSON.stringify(data))
    axios.post('/sender/' + sender_id + '/contact_new', data)
      .then((response) => reloadOrPrintError(response, 'adding contact'))
      .catch((error) => {
        console.error(error)
      })
  }
}

function fetchSenderAccounts(sender_id) {
  axios.get('/json/sender/' + sender_id + '/accounts')
    .then((response) => {
      const data = response.data
      let accBox = document.getElementById('senderaccounts')
      removeAllOptions(accBox)
      accBox.appendChild(createOption('', '- none -'))
      let noOptions = true
      for (let acc of data) {
        // console.log(acc.id + ': ' + acc.account_number)
        const opt = createOption(acc.id, acc.account_number)
        accBox.appendChild(opt)
        noOptions = false
      }
      accBox.disabled = noOptions

      // need to regenerate select options based on the elements
    })
    .catch((error) => {
      console.error(error)
    })
}

function deleteAccount(sa_id) {
  if (confirm('Are you sure??')) {
    axios.delete('/senderaccount/' + sa_id)
      .then((response) => reloadOrPrintError(response, 'deleting account'))
      .catch((error) => {
        console.error(error)
      })
  }
}

function deleteContact(sa_id) {
  if (confirm('Are you sure??')) {
    axios.delete('/sendercontact/' + sa_id)
      .then((response) => reloadOrPrintError(response, 'deleting contact'))
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
      .then((response) => reloadOrPrintError(response, 'updating account'))
      .catch((error) => {
        console.error(error)
      })
  }
}

function updateContact(topEl) {
  const containerDiv = document.getElementById(topEl)
  const data = collectElementsOfFrom('fieldval', containerDiv)

  if (typeof data !== 'undefined') {
    console.log(JSON.stringify(data))
    axios.post('/sendercontact/' + data.id, data)
      .then((response) => reloadOrPrintError(response, 'updating contact'))
      .catch((error) => {
        console.error(error)
      })
  }
}

function toggleShowAccount() {
  let sa = document.getElementById('newaccount')
  sa.classList.toggle('hidden')
}

function toggleShowContact() {
  let sc = document.getElementById('newcontact')
  sc.classList.toggle('hidden')
}

function toggleTagMenu(sender_id) {
  let taglist = document.getElementById('taglist')
  const allTagNames = senderTags()
  if (taglist.classList.contains('hidden')) {
    axios.get('/tags')
      .then((response) => {
        const tags = response.data
        for (let tag of tags) { // id, description
          if (allTagNames.indexOf(tag.description) == -1) {
            let newtag = document.createElement('li')
            newtag.innerHTML = tag.description
            newtag.onclick = function () { addTag(sender_id, tag.id) }
            taglist.appendChild(newtag)
          }
        }
        document.getElementById('taglist').classList.remove('hidden')
      })
      .catch((error) => {
        console.error(error)
      })
  } else {
    hideTagMenu()
  }

}

function senderTags() {
  let ret = []
  const taglist = document.getElementById('sendertags')
  for (t of taglist.children) {
    if (t.nodeName == 'BUTTON') {
      if (t.innerText != 'Add') {
        ret.push(t.innerText)
      }
    }
  }
  return ret
}
function hideTagMenu() {
  document.getElementById('taglist').classList.add('hidden')
  document.getElementById('taglist').innerHTML = ''
}

function addTag(sender_id, tag_id) {
  console.log('adding tag for sender ' + sender_id + ', tag ' + tag_id)
  axios.post('/sendertag/' + sender_id + '/' + tag_id)
    .then((response) => reloadOrPrintError(response, 'adding tag to sender'))
    .catch((error) => {
      console.error(error)
    })

  hideTagMenu()
}
function delTag(sender_id, tag_id) {
  if (confirm('Are you sure you want to remove this tag?')) {
    axios.delete('/sendertag/' + sender_id + '/' + tag_id)
      .then((response) => reloadOrPrintError(response, 'adding tag to sender'))
      .catch((error) => {
        console.error(error)
      })

  }
}