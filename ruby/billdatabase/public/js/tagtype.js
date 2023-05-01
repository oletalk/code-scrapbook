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
      .then((response) => reloadOrPrintError(response, 'updating tag type'))
      .catch((error) => {
        console.error(error)
      })

  }

}