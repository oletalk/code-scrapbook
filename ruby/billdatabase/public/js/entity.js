function go(url) {
  window.location.replace(url)
}

function toggleShowAccount() {
  let sa = document.getElementById('newaccount')
  sa.classList.toggle('hidden')
}

function addSender() {
  const data = collectElementsOfFrom('sender_field', document)
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

function updateSender(sid) {
  const data = collectElementsOfFrom('sender_field', document)

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

function addAccount(sender_id) {
  const containerDiv = document.getElementById('account_new')
  let data = collectElementsOfFrom('fieldval', containerDiv)
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

  //       location.reload()
}

function updateAccount(topEl) {
  const containerDiv = document.getElementById(topEl)
  const data = collectElementsOfFrom('fieldval', containerDiv)
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

// utility methods
function collectElementsOfFrom(className, containerElement) {
  let data = {}
  for (field of containerElement.getElementsByClassName(className)) {
    data[field.name] = field.value
  }

  return data
}
// 'mounted' follows