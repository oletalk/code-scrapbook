function foo() {
  alert('hello')
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
function updateAccount(topEl) {
  const containerDiv = document.getElementById(topEl)
  const data = collectElementsOfFrom('fieldval', containerDiv)
  console.log(JSON.stringify(data))
  const sender_id = topEl.split('_')[1]
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