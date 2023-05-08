function updateColor(tag_id, color) {
  const color_val = document.getElementById(color).value
  console.log('updating color for tag ' + tag_id + ' to ' + color_val)
  const data = {
    color: color_val
  }
  axios.post('/tagtype/' + tag_id, data)
    .then((response) => reloadOrPrintError(response, 'updating tag type'))
    .catch((error) => {
      console.error(error)
    })

}

function addTag() {
  const color_val = document.getElementById('new_color').value
  const tag_name = document.getElementById('new_tag').value
  if (tag_name == '' || color_val == '#000000') {
    alert('please select both a name and a color for the tag')
  } else {
    console.log('saving new tag with name "' + tag_name + '" and color ' + color_val)
    const data = {
      tag_type: tag_name,
      color: color_val
    }
    axios.post('/tagtype_new', data)
      .then((response) => reloadOrPrintError(response, 'adding tag type'))
      .catch((error) => {
        console.error(error)
      })

  }

}

function colorTags() {
  axios.get('/json/sendertags')
    .then((response) => {
      const allSenders = response.data
      for (sender of allSenders) {
        const senderTags = sender.sender_tags
        // use the first one for now
        const tag = senderTags[0]
        const tr_name = 'doc_tr_' + sender.id
        const trs = document.getElementsByClassName(tr_name)
        if (typeof trs !== 'undefined' && trs != null) {
          for (const tr of trs) {
            const row = tr.getElementsByTagName('TD')
            for (let td of row) {
              if (!(td.classList.contains('accountnumber'))) {
                td.style['color'] = tag.color
              }
            }
          }
        } else {
          console.error('could not find element "' + tr_name + '"')
        }
      }
    })
    .catch((error) => {
      console.error(error)
    })

}